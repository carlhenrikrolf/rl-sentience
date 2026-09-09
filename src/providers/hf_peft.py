"""An Inspect model provider that attaches a PEFT/LoRA adapter to a base model.

Inspect's built-in `hf/` provider loads models with
`AutoModelForCausalLM.from_pretrained(...)` and never imports peft, so it cannot serve a
LoRA adapter. Han et al. publish no weights, and the reproduction adapters we use
(`davidafrica/functional-wellbeing`) are adapter-only repositories: no `config.json`, no
base weights, and each checkpoint lives in a *subfolder* of one repo.

Keeping the adapter unmerged means the base and LoRA cohorts share a single ~8 GB copy of
the base model rather than one merged copy per condition, which matters both on a 16 GB
machine and once the aversive/positive conditions are added.

Usage::

    # LoRA cohort
    --model hf-peft/Qwen/Qwen3-4B-Instruct-2507 \\
      -M adapter=davidafrica/functional-wellbeing \\
      -M subfolder=checkpoints/qwen3-4b_faithful_step400

    # base cohort: same provider, omit `adapter`
    --model hf-peft/Qwen/Qwen3-4B-Instruct-2507

`inspect_ai.model._providers.hf` is a private module, so `inspect-ai` is pinned in
`pyproject.toml`. If a future release breaks this subclass, the documented fallback is a
full `ModelAPI` implementation: https://inspect.aisi.org.uk/extensions-model-api.html
"""

from __future__ import annotations

from typing import Any

from inspect_ai.model import GenerateConfig
from inspect_ai.model._providers.hf import HuggingFaceAPI


class HFPeftAPI(HuggingFaceAPI):
    """`HuggingFaceAPI` plus an optional PEFT adapter applied after the base loads."""

    def __init__(
        self,
        model_name: str,
        base_url: str | None = None,
        api_key: str | None = None,
        config: GenerateConfig = GenerateConfig(),
        *,
        adapter: str | None = None,
        subfolder: str | None = None,
        adapter_revision: str | None = None,
        **model_args: Any,
    ) -> None:
        # Loads the base model and selects a device (mps on Apple Silicon) for us.
        super().__init__(
            model_name,
            base_url=base_url,
            api_key=api_key,
            config=config,
            **model_args,
        )

        self.adapter = adapter
        self.subfolder = subfolder

        if adapter is None:
            return

        from peft import PeftModel

        self.model = PeftModel.from_pretrained(
            self.model,
            adapter,
            subfolder=subfolder,
            revision=adapter_revision,
            is_trainable=False,
        )
        self.model.eval()

    def is_lora(self) -> bool:
        """True when an adapter is attached (i.e. this is the LoRA cohort)."""
        return self.adapter is not None
