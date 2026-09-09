"""Registration of this project's custom Inspect model providers.

`pyproject.toml` sets `package = false` under `[tool.uv]`, so this project is an
environment spec rather than an installable package and cannot register providers through
the `[project.entry-points.inspect_ai]` mechanism. Task files import this module directly
instead; `@modelapi` registers the provider at import time, which happens before Inspect
resolves `--model`.
"""

from __future__ import annotations

from inspect_ai.model import ModelAPI, modelapi


@modelapi(name="hf-peft")
def hf_peft() -> type[ModelAPI]:
    # Imported lazily so that merely registering the provider does not pull in
    # torch / transformers / peft.
    from src.providers.hf_peft import HFPeftAPI

    return HFPeftAPI
