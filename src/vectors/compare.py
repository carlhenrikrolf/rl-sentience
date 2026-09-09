"""Compare our extracted vectors against the published reproduction's.

This is the one external correctness anchor available for the interpretability half.
`davidafrica/functional-wellbeing` publishes `concept_vectors/qwen3-4b_step400/{lava,goal,
path}/mean_diff.pt` at 0.74 MB each, so the check is nearly free.

**Assumption to verify before trusting the result**: that `qwen3-4b_step400` is the same
training run as the `qwen3-4b_faithful_step400` adapter. Its metadata records
`checkpoint_path: runs/run2/global_step_400`, which is suggestive but not conclusive — the
repo also contains a separate `welfarescope-faithful_step200`. If the runs differ, a low
cosine says nothing.

Note the published vectors were extracted at `n_per_tile_requested: 300` with upstream's
own layer conventions, so expect agreement in *direction*, not identity.

Usage::

    python -m src.vectors.compare --ours vectors/qwen3-4b_faithful_step400
"""

from __future__ import annotations

import argparse
import json
import pathlib
import sys

_ROOT = str(pathlib.Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

import torch  # noqa: E402

PUBLISHED_REPO = "davidafrica/functional-wellbeing"
PUBLISHED_PREFIX = "concept_vectors/qwen3-4b_step400"
CONCEPTS = ("lava", "goal", "path")


def _canonical(t: torch.Tensor) -> torch.Tensor:
    """Drop a leading singleton n_positions axis, so (1, L, D) and (L, D) compare."""
    while t.dim() > 2 and t.shape[0] == 1:
        t = t.squeeze(0)
    return t


def fetch_published(concept: str, cache_dir: str | None = None) -> torch.Tensor:
    """Download one published `mean_diff.pt` (~0.74 MB) from the Hub."""
    from huggingface_hub import hf_hub_download

    path = hf_hub_download(
        repo_id=PUBLISHED_REPO,
        filename=f"{PUBLISHED_PREFIX}/{concept}/mean_diff.pt",
        cache_dir=cache_dir,
    )
    return torch.load(path, map_location="cpu")


def compare(ours_dir: pathlib.Path, cache_dir: str | None = None) -> dict:
    """Per-layer cosine between our vectors and the published ones."""
    cos = torch.nn.functional.cosine_similarity
    report: dict = {"published": f"{PUBLISHED_REPO}/{PUBLISHED_PREFIX}", "concepts": {}}

    for concept in CONCEPTS:
        ours_path = ours_dir / concept / "mean_diff.pt"
        if not ours_path.exists():
            report["concepts"][concept] = {"error": f"missing {ours_path}"}
            continue

        ours = _canonical(torch.load(ours_path, map_location="cpu").float())
        theirs = _canonical(fetch_published(concept, cache_dir).float())

        if ours.shape != theirs.shape:
            report["concepts"][concept] = {
                "error": "shape mismatch", "ours": list(ours.shape), "theirs": list(theirs.shape)
            }
            continue

        per_layer = cos(ours, theirs, dim=-1).flatten()
        n = per_layer.shape[0]
        report["concepts"][concept] = {
            "shape": list(ours.shape),
            "cos_mean": float(per_layer.mean()),
            "cos_late_third": float(per_layer[2 * n // 3 :].mean()),
            "cos_min": float(per_layer.min()),
            "cos_max": float(per_layer.max()),
        }

    # The paper's headline readout for this checkpoint is cos(vMOLD, vGOLD) = -0.54.
    lava_p, goal_p = ours_dir / "lava" / "mean_diff.pt", ours_dir / "goal" / "mean_diff.pt"
    if lava_p.exists() and goal_p.exists():
        v_lava = _canonical(torch.load(lava_p, map_location="cpu").float())
        v_goal = _canonical(torch.load(goal_p, map_location="cpu").float())
        per_layer = cos(v_lava, v_goal, dim=-1).flatten()
        n = per_layer.shape[0]
        report["cos_vMOLD_vGOLD_late_third"] = float(per_layer[2 * n // 3 :].mean())
        report["reported_by_replication"] = -0.54

    return report


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--ours", required=True, type=pathlib.Path)
    p.add_argument("--cache-dir", default=None)
    args = p.parse_args()
    print(json.dumps(compare(args.ours, args.cache_dir), indent=2))


if __name__ == "__main__":
    main()
