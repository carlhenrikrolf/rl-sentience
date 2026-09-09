"""Capture residual-stream activations at the final assistant-turn token.

Replaces upstream's `concept_vector.activation_extraction.get_all_tile_activations`, which
cannot run on Apple Silicon: it pre-allocates its accumulators as

    torch.zeros(..., dtype=torch.float64, device=model.device)

and MPS has no float64 (`TypeError: Cannot convert a MPS Tensor to float64 dtype`). Upstream
ran on CUDA, where that is fine. We keep the float64 accumulation — it is worth having for
numerical stability across hundreds of samples — but do it on the CPU, and keep only the
device-side tensors in the model's own dtype.

Conventions kept identical to upstream so that vectors are comparable with the published
ones:

- **Position**: the last token of the formatted trajectory, which is the direction letter
  (N/E/S/W), *not* an `<|im_end|>`. Upstream's `format_trajectory` documents this: it "does
  NOT add `<|im_end|>` after the final assistant message, so the last token is the actual
  move direction". We get the same by templating all but the final message with
  `add_generation_prompt=True` and concatenating the final assistant content.
- **Layers**: 36 for Qwen3-4B, the residual stream *entering* each transformer block.
  `output_hidden_states=True` returns 37 tensors — the embedding output plus one per block —
  so `hidden_states[i]` is the input to block `i` and we drop the last. This matches the
  published `mean_diff.pt` shape (36, 2560) at 0.74 MB in float64.
- **Padding**: left, so index `-1` is the last real token for every sequence in a batch.
"""

from __future__ import annotations

import sys
from pathlib import Path

_ROOT = str(Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

import torch  # noqa: E402
from tqdm import tqdm  # noqa: E402


def format_trajectory(messages: list[dict], tokenizer) -> str:
    """Render a trajectory so the final token is the direction letter.

    The final assistant message is appended raw rather than templated, so no end-of-turn
    marker follows it.
    """
    if not messages or messages[-1]["role"] != "assistant":
        raise ValueError("trajectory must end with an assistant message")

    prefix = tokenizer.apply_chat_template(
        messages[:-1], tokenize=False, add_generation_prompt=True
    )
    return prefix + messages[-1]["content"]


@torch.no_grad()
def capture_final_token_activations(
    model,
    tokenizer,
    trajectories_by_tile: dict[str, list[list[dict]]],
    *,
    batch_size: int = 4,
    verbose: bool = True,
) -> dict[str, dict]:
    """Mean residual-stream activation at the final token, per tile class.

    Returns ``{tile: {"mean": Tensor(n_positions=1, n_layers, d_model) float64 on CPU,
    "count": int}}``. The leading axis is vestigial — we only ever capture position -1 —
    but the published vectors carry it, so keeping it makes the two directly comparable.
    """
    results: dict[str, dict] = {}

    for tile_type, trajectories in trajectories_by_tile.items():
        if not trajectories:
            raise ValueError(f"No trajectories for {tile_type}")

        total: torch.Tensor | None = None
        count = 0
        batches = range(0, len(trajectories), batch_size)
        iterator = tqdm(batches, desc=f"  {tile_type}", disable=not verbose)

        for start in iterator:
            batch = trajectories[start : start + batch_size]
            texts = [format_trajectory(m, tokenizer) for m in batch]

            encoded = tokenizer(texts, return_tensors="pt", padding=True)
            encoded = {k: v.to(model.device) for k, v in encoded.items()}

            out = model(**encoded, output_hidden_states=True, use_cache=False)

            # hidden_states[i] is the input to block i; drop the final block's output so
            # the layer count matches upstream's block-input convention.
            per_layer = [h[:, -1, :] for h in out.hidden_states[:-1]]
            acts = torch.stack(per_layer, dim=1)  # (batch, n_layers, d_model)

            # float64 accumulation on CPU — MPS has no float64. Move the device FIRST and
            # cast second: `acts.to("cpu", dtype=torch.float64)` in one call lets torch
            # attempt the bfloat16 -> float64 conversion on the source device, which MPS
            # cannot do. It does not raise; it yields zeros, so every class mean comes out
            # identical and every difference vector is exactly zero.
            acts64 = acts.detach().to("cpu").to(torch.float64)
            batch_sum = acts64.sum(dim=0)
            total = batch_sum if total is None else total + batch_sum
            count += acts64.shape[0]

            del out, per_layer, acts, acts64

        assert total is not None
        # (n_layers, d_model) -> (1, n_layers, d_model), matching upstream's
        # (n_positions, n_layers, d_model).
        results[tile_type] = {"mean": (total / count).unsqueeze(0), "count": count}
        if verbose:
            print(f"  {tile_type}: count={count}, mean_norm={results[tile_type]['mean'].norm():.4f}")

    return results
