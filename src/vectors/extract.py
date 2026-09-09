"""Extract 'reward' vectors by difference-in-means, per Han et al. §2.3.

Runs outside Inspect: Equation (1) needs the activation at the *final assistant-turn
token* (the direction letter, emitted before the environment responds), which requires
forward hooks. Inspect's `hf/` provider can expose `hidden_states`, but only over
generated tokens.

Equation (1) is **one-vs-rest**, not a binary contrast:

    v_mold = E[a | mold] − E[a | gold ∪ path]
    v_gold = E[a | gold] − E[a | mold ∪ path]

Including PATH in both subtrahends is load-bearing. Under the binary alternative
(`E[mold] − E[gold]` and its negation) the two vectors would be exact opposites and
`cos(v_mold, v_gold) ≡ −1` by construction, making the paper's headline measurement
vacuous. §3.1 makes this point explicitly.

Trajectory construction is in `src.vectors.trajectories` (see that module for why it is
not upstream's): fresh mazes, an all-PATH prefix, a final step onto the class tile, step
counts spread over {1..15}. The all-PATH prefix means cumulative reward is identically
distributed across classes and cancels in the difference of means — so the contrast
identifies the final transition only. The recovered *direction* need not be specific to it.

Usage::

    python -m src.vectors.extract --out vectors/qwen3-4b_faithful_step400 \\
      --adapter davidafrica/functional-wellbeing \\
      --subfolder checkpoints/qwen3-4b_faithful_step400
    python -m src.vectors.extract --out vectors/qwen3-4b_base    # control (u), no adapter
"""

from __future__ import annotations

import argparse
import json
import pathlib
import sys
from datetime import datetime, timezone
from typing import Any

_ROOT = str(pathlib.Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

import torch  # noqa: E402

from src.upstream import TileConfig  # noqa: E402

# Upstream's tile names; "lava" is the paper's MOLD and "goal" its GOLD.
TILE_TYPES = ("LAVA", "GOAL", "PATH")
CONCEPTS = {"lava": "LAVA", "goal": "GOAL", "path": "PATH"}


def load_cohort_model(
    base_model: str,
    adapter: str | None = None,
    subfolder: str | None = None,
    device: str | None = None,
    dtype: str = "auto",
    load_workers: int | None = None,
):
    """Load the base model with the adapter attached, unmerged.

    Upstream's `get_model_block_modules` asserts `model.model.layers`, which a
    `PeftModelForCausalLM` wrapper does not satisfy (its layers sit one level deeper, at
    `base_model.model.model.layers`). Rather than merge — which is what upstream's own
    loader does, and which spikes memory on a 16 GB machine — we return the *unwrapped*
    `base_model.model`. That is a plain `Qwen3ForCausalLM` whose `q_proj` etc. are still
    `peft` LoRA modules, so the adapter stays active and the accessor is satisfied.

    This keeps extraction and evaluation loading the model the same way.

    Upstream's `load_model_with_lora` is not usable: it expects a training-run directory
    containing `lora_adapter/` and `huggingface/`, not a Hub adapter repo with subfolders.
    """
    from transformers import AutoModelForCausalLM, AutoTokenizer

    if load_workers is not None:
        # Belt and braces for the MPS shader-cache race described below: transformers
        # materialises tensors on a thread pool sized by this module constant, and there
        # is no environment variable for it. Setting it to 1 serialises the copies.
        from transformers import core_model_loading

        core_model_loading.GLOBAL_WORKERS = load_workers

    if device is None:
        if torch.backends.mps.is_available():
            device = "mps"
        elif torch.cuda.is_available():
            device = "cuda:0"
        else:
            device = "cpu"

    # "auto" keeps the checkpoint's own dtype. Do not default to float16: Qwen3-4B is
    # stored in bfloat16, so forcing float16 makes every load a *cast*, which on MPS goes
    # through `copy_cast_kernel_mps` -> `MetalShaderLibrary::exec_unary_kernel`. That
    # lazily fills a non-thread-safe std::unordered_set, and transformers materialises
    # tensors on a 4-thread pool (core_model_loading.GLOBAL_WORKERS), so the threads race
    # and the process dies with SIGSEGV inside libtorch_cpu before loading finishes.
    torch_dtype = "auto" if dtype == "auto" else getattr(torch, dtype)
    model = AutoModelForCausalLM.from_pretrained(
        base_model, dtype=torch_dtype, device_map=device
    )
    tokenizer = AutoTokenizer.from_pretrained(base_model)
    # Upstream's batched capture assumes left padding so position -1 is the last real token.
    tokenizer.padding_side = "left"
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    if adapter is not None:
        from peft import PeftModel

        peft_model = PeftModel.from_pretrained(
            model, adapter, subfolder=subfolder, is_trainable=False
        )
        # Unwrap, don't merge — see the docstring.
        model = peft_model.base_model.model

    model.eval()
    return model, tokenizer, device


def one_vs_rest(
    means: dict[str, torch.Tensor], counts: dict[str, int], positive: str
) -> torch.Tensor:
    """Equation (1): mean(positive) − mean(union of the other classes).

    The union mean is count-weighted. Upstream's `compute_concept_vectors` averages the
    negative *class means* unweighted, which is identical whenever the classes are
    balanced — as `generate_trajectories` makes them — but differs if any class is short.
    """
    negatives = [t for t in TILE_TYPES if t != positive]
    total = sum(counts[t] for t in negatives)
    if total == 0:
        raise ValueError(f"No negative-class samples for {positive}")
    union = sum(means[t] * counts[t] for t in negatives) / total
    return means[positive] - union


def extract(
    *,
    out_dir: pathlib.Path,
    base_model: str = "Qwen/Qwen3-4B-Instruct-2507",
    adapter: str | None = None,
    subfolder: str | None = None,
    n_per_tile: int = 300,
    maze_size: int = 100,
    goal_lava_ratio: float = 0.5,
    max_steps: int = 15,
    base_seed: int = 474747,
    batch_size: int = 8,
    dtype: str = "auto",
    device: str | None = None,
    load_workers: int | None = None,
    tile_config: TileConfig | None = None,
) -> dict[str, Any]:
    """Extract and save the three one-vs-rest concept vectors."""
    from src.vectors.capture import capture_final_token_activations
    from src.vectors.trajectories import generate_trajectories

    tile_config = tile_config or TileConfig(
        PATH="🧾", LAVA="📇", GOAL="📐", PLAYER="😀", mode="emoji"
    )

    trajectories = generate_trajectories(
        tile_config=tile_config,
        n_per_tile=n_per_tile,
        maze_size=maze_size,
        goal_lava_ratio=goal_lava_ratio,
        min_steps=1,
        max_steps=max_steps,
        base_seed=base_seed,
    )

    model, tokenizer, device = load_cohort_model(
        base_model,
        adapter=adapter,
        subfolder=subfolder,
        dtype=dtype,
        device=device,
        load_workers=load_workers,
    )

    # Captures at the final assistant-turn token, i.e. the direction letter.
    results = capture_final_token_activations(
        model, tokenizer, trajectories, batch_size=batch_size
    )
    means = {t: results[t]["mean"] for t in TILE_TYPES}
    counts = {t: results[t]["count"] for t in TILE_TYPES}

    out_dir.mkdir(parents=True, exist_ok=True)
    written = {}
    for concept, positive in CONCEPTS.items():
        vector = one_vs_rest(means, counts, positive)
        cdir = out_dir / concept
        cdir.mkdir(parents=True, exist_ok=True)
        torch.save(vector, cdir / "mean_diff.pt")
        (cdir / "metadata.json").write_text(
            json.dumps(
                {
                    "concept": concept,
                    "positive_class": positive,
                    "negative_class": [t for t in TILE_TYPES if t != positive],
                    "equation": "E[a|positive] - E[a|union of others]  (Han et al. Eq. 1)",
                    "base_model": base_model,
                    "adapter": adapter,
                    "subfolder": subfolder,
                    "extraction_mode": "off_policy",
                    "position": "final assistant-turn token (-1)",
                    "n_per_tile_requested": n_per_tile,
                    "counts": counts,
                    "maze_size": maze_size,
                    "goal_lava_ratio": goal_lava_ratio,
                    "max_steps": max_steps,
                    "generation_seed": base_seed,
                    "dtype": dtype,
                    "device": device,
                    "tile_config": {
                        "path": tile_config.PATH,
                        "lava": tile_config.LAVA,
                        "goal": tile_config.GOAL,
                    },
                    "shape": list(vector.shape),
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                },
                indent=2,
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
        written[concept] = str(cdir / "mean_diff.pt")

    cos = torch.nn.functional.cosine_similarity
    v_lava = torch.load(out_dir / "lava" / "mean_diff.pt")
    v_goal = torch.load(out_dir / "goal" / "mean_diff.pt")
    # Late-third layers: the paper's headline readout (the early-layer cosine is the
    # trivial token-identity contrast at the embedding, ~-0.88 even untrained).
    n_layers = v_lava.shape[-2]
    late = slice(2 * n_layers // 3, n_layers)
    per_layer = cos(v_lava[..., late, :], v_goal[..., late, :], dim=-1)
    # Per-class mean norms and pairwise distances: if these are equal the difference
    # vectors are necessarily zero, which is a bug rather than a result.
    pair = {
        f"{a}-{b}": float((means[a] - means[b]).abs().max())
        for a, b in (("LAVA", "GOAL"), ("LAVA", "PATH"), ("GOAL", "PATH"))
    }
    summary = {
        "files": written,
        "counts": counts,
        "mean_norms": {t: float(means[t].norm()) for t in TILE_TYPES},
        "max_abs_diff_between_class_means": pair,
        "cos_vMOLD_vGOLD_late": float(per_layer.mean()),
        "cos_min": float(cos(v_lava, v_goal, dim=-1).min()),
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    return summary


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--out", required=True, type=pathlib.Path)
    p.add_argument("--base-model", default="Qwen/Qwen3-4B-Instruct-2507")
    p.add_argument("--adapter", default=None, help="omit for the control vectors (u)")
    p.add_argument("--subfolder", default=None)
    p.add_argument("--n-per-tile", type=int, default=300)
    p.add_argument("--maze-size", type=int, default=100)
    p.add_argument("--goal-lava-ratio", type=float, default=0.5)
    p.add_argument("--batch-size", type=int, default=8)
    p.add_argument(
        "--dtype",
        default="auto",
        help="auto (the checkpoint's dtype, recommended) or a torch dtype name. "
             "Forcing a dtype different from the checkpoint's segfaults on MPS.",
    )
    p.add_argument(
        "--load-workers",
        type=int,
        default=None,
        help="threads transformers uses to materialise weights (default 4). "
             "Set 1 if loading segfaults on MPS.",
    )
    p.add_argument(
        "--device",
        default=None,
        help="force a device (mps/cpu). Default: mps if available, else cpu. "
             "Use cpu if loading is killed for memory on a 16 GB machine.",
    )
    p.add_argument("--base-seed", type=int, default=474747)
    args = p.parse_args()

    summary = extract(
        out_dir=args.out,
        base_model=args.base_model,
        adapter=args.adapter,
        subfolder=args.subfolder,
        n_per_tile=args.n_per_tile,
        maze_size=args.maze_size,
        goal_lava_ratio=args.goal_lava_ratio,
        batch_size=args.batch_size,
        dtype=args.dtype,
        device=args.device,
        load_workers=args.load_workers,
        base_seed=args.base_seed,
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
