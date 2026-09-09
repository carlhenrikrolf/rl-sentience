"""Wrapper around the `inspect` CLI that registers this project's model providers first.

Inspect discovers custom providers through setuptools entry points in the `inspect_ai`
group, which requires the project to be an installed distribution. `pyproject.toml` sets
`package = false` — this is an environment spec, not a package — so there is no
distribution metadata for Inspect to read.

Importing `src.providers._registry` from inside a *task file* does not help: Inspect
resolves `--model` before it loads the task, so `--model hf-peft/...` fails with
"Model API hf-peft ... not recognized". This wrapper imports the registry first and then
hands over to Inspect's own CLI, so every flag behaves exactly as it does under `inspect`.

Usage — substitute for `inspect` anywhere::

    uv run python -m src.run eval src/maze/task.py --task-config config/maze.yaml \\
      --model hf-peft/Qwen/Qwen3-4B-Instruct-2507 \\
      -M adapter=davidafrica/functional-wellbeing \\
      -M subfolder=checkpoints/qwen3-4b_faithful_step400

The plain `inspect` command still works for anything that does not need `hf-peft`
(`mockllm/`, `google/`, `hf/`, ...).
"""

from __future__ import annotations

import pathlib
import sys

_ROOT = str(pathlib.Path(__file__).resolve().parents[1])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

import src.providers._registry  # noqa: F401,E402  (registers `hf-peft` before Inspect looks)
from inspect_ai._cli.main import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main())
