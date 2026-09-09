# Install

Setup for a fresh clone, and how to run each part of the work.

## Prerequisites

- **Python ≥ 3.12** (the checked-in environment uses 3.13)
- **[uv](https://docs.astral.sh/uv/)** for Python dependency management
- **git** with submodule support
- **[elan](https://github.com/leanprover/elan)** if you want the Lean side
- ~10 GB free disk for model weights, plus a Hugging Face account for downloads

## Setup

```bash
git clone <this repo> rl-sentience
cd rl-sentience

# third_party/functional-welfare-axis is a submodule pinned to the upstream code of
# Han et al. (github.com/andyqhan/functional-welfare-axis).
git submodule update --init --recursive

uv sync
```

`uv sync` creates `.venv/` and installs everything in `pyproject.toml`, including the two
pinned dependencies that matter:

- `inspect-ai == 0.3.260` — `src/providers/hf_peft.py` subclasses a private Inspect module,
  so a floating version is the main breakage risk.
- `peft == 0.19.1` — the version the reproduction adapters were saved with.

### Untracked directories

Some directories are deliberately not in git and will not appear on a fresh clone:

| directory | contents |
|---|---|
| `references/` | PDFs of the papers. Read them with poppler (`pdftotext -layout`). |
| `tmp/` | scratch space — plans, summaries, throwaway output |
| `logs/` | Inspect `.eval` logs (the default `--log-dir`) |

### Secrets

Create `.env` in the repo root. Inspect reads it automatically from the working directory.

```bash
GOOGLE_API_KEY=...        # Gemini, used as the sentiment judge
HF_TOKEN=...              # Hugging Face downloads

# Optional Inspect runner settings (these are environment variables, not task arguments)
INSPECT_EVAL_MAX_CONNECTIONS=1
INSPECT_EVAL_LIMIT=2
INSPECT_EVAL_EPOCHS=1
INSPECT_LOG_DIR=./logs
```

## Running the reproduction

See `docs/experiments/reproduction.md` for what these experiments are and why.
Task parameters live in `config/*.yaml`; see `config/reproduction.yaml` for the split
between task arguments and environment variables.

### Custom model provider

The `hf-peft` provider (`src/providers/`) is registered with Inspect through a setuptools
entry point declared in `pyproject.toml`. This requires the project to be installed, which
`uv sync` does — so run it before your first eval. With it in place, plain `inspect eval`
works, and so does the **VS Code Inspect extension**, which shells out to `inspect` itself.

If `--model hf-peft/...` ever fails with *"Model API hf-peft not recognized"*, the project
is not installed in the active environment; re-run `uv sync`. As a fallback that needs no
install, `python -m src.run` wraps the same CLI and registers the provider first:

```bash
uv run python -m src.run eval ...     # equivalent to: inspect eval ...
```

### Cohorts

Both cohorts use the `hf-peft` provider and share one copy of the base weights, because the
adapter is attached at load time rather than merged.

```bash
# base cohort
BASE="hf-peft/Qwen/Qwen3-4B-Instruct-2507"

# LoRA cohort (Han et al. published no weights; these are a reproduction's)
LORA_ARGS="-M adapter=davidafrica/functional-wellbeing \
           -M subfolder=checkpoints/qwen3-4b_faithful_step400"
```

### 1. Wiring check, no model

Confirms the dataset, solver loop, scorer and metrics without downloading anything.

```bash
uv run inspect eval src/maze/task.py --model mockllm/model \
  -T num_mazes=3 -T maze_size=11 -T max_turns=5 -T wind_frequency=0.0
```

Expect every episode to end as `invalid_output` with reward 0 — mockllm returns fixed prose,
not a direction. That is the correct result.

### 2. Scoring — the maze

```bash
uv run inspect eval src/maze/task.py --task-config config/maze.yaml --model "$BASE"
uv run inspect eval src/maze/task.py --task-config config/maze.yaml --model "$BASE" $LORA_ARGS
```

First run downloads Qwen3-4B-Instruct-2507 (~8 GB) into the Hugging Face cache.

A gap between cohorts confirms only that the adapter is attached — it is a load-check, not
evidence of the phenomenon. Han et al.'s own Llama-3.1-8B never solves the maze yet shows
the strongest recruitment.

### 3. Evaluation — off-task sentiment

```bash
uv run inspect eval src/eval/sentiment.py --task-config config/sentiment.yaml \
  --model "$BASE" $LORA_ARGS
```

Read results **split by prompt category**. The paper's Appendix A.3 reports the 15 welfare
self-report prompts as essentially flat, with the effect carried by the 25 maze-tile
associations, so an aggregate over all 40 can hide a real result. The scorer emits a
`grouped(mean(), "category")` metric for exactly this.

### 4. Interpretability — difference-in-means vectors

Runs outside Inspect: Equation (1) needs the activation at the final assistant-turn token,
which requires forward hooks.

```bash
# trained vectors (v)
uv run python -m src.vectors.extract --out vectors/qwen3-4b_faithful_step400 \
  --adapter davidafrica/functional-wellbeing \
  --subfolder checkpoints/qwen3-4b_faithful_step400

# control vectors (u) — same pipeline, maze-naive model
uv run python -m src.vectors.extract --out vectors/qwen3-4b_base

# compare against the published reproduction's vectors
uv run python -m src.vectors.compare --ours vectors/qwen3-4b_faithful_step400
```

### Viewing logs

```bash
uv run inspect view            # browser UI over ./logs
```

The **Inspect AI** VS Code extension reads the same directory. Point the Python extension's
interpreter at `.venv` or the extension will not find `inspect_ai`.

## Hardware notes

Developed on an M3 MacBook with 16 GB unified memory. Inspect's `hf/` provider selects
`mps` automatically.

- **Qwen3-4B** at fp16 is ~8 GB and fits, with little headroom.
- **Qwen3-8B and larger will not fit** at fp16. For those, use a rented GPU or
  [molab](https://molab.marimo.io), which offers a free GPU with 96 GB VRAM.
- Vector extraction is forward passes only — no gradients — so 300 trajectories per tile
  class is comfortable locally. Start a first run small (`--n-per-tile 20 --batch-size 4`)
  to see the memory profile before committing.
- **Measured on CPU** (MPS unavailable), extraction ran ~39 s per batch of 3 trajectories,
  which would put 300/class near 3 hours. On MPS expect substantially less. If
  `torch.backends.mps.is_available()` returns `False` on a machine running macOS 14+,
  something is blocking GPU device creation — a sandbox, for instance — and everything will
  silently fall back to CPU.

### Troubleshooting: segfault while loading weights on MPS

If a run dies during "Loading weights" with no Python traceback — just a leaked-semaphore
warning — check `~/Library/Logs/DiagnosticReports/` for a `Python-*.ips`. A crash inside
`at::native::mps::copy_cast_kernel_mps` -> `MetalShaderLibrary::exec_unary_kernel`, with
several threads in the same `std::__hash_table::__emplace_unique_key_args`, is a data race
in torch's Metal shader cache, not a memory problem.

It is triggered by **casting** during load. Qwen3-4B is stored in bfloat16, so asking for
float16 makes every tensor copy a cast, and transformers materialises tensors on a
four-thread pool (`core_model_loading.GLOBAL_WORKERS`), so the threads race in an
unsynchronised hash table.

Avoid it by not forcing a dtype — `--dtype auto` is the default and keeps the checkpoint's
own. If it still happens, serialise the load:

```bash
uv run python -m src.vectors.extract ... --load-workers 1
```

The same applies to evals: don't pass `-M dtype=...` unless it matches the checkpoint.
Inspect passes no dtype by default, so `inspect eval` is unaffected.

## Lean

The Lean project is independent of the Python work.

```bash
lake exe cache get    # prebuilt Mathlib oleans
lake build
```

The toolchain is pinned to `leanprover/lean4:v4.28.0` with Mathlib at the matching tag, for
compatibility with Aristotle / harmonic.fun. **Do not bump it** without checking that first.
