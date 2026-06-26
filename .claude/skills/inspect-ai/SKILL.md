---
name: inspect-ai
description: Build and run UK AISI Inspect (inspect_ai) evals - Task = dataset + solver + scorer, custom @solver/@scorer/@metric, model providers (vllm/ to a running server, mistral/, google/, openai-api/, mockllm/), .env handling, the VSCode "Inspect AI" extension, and the NaN/unscored-sample metric behavior. Use when writing or running inspect eval tasks, wiring LLM-judge scoring, choosing model providers, or debugging Inspect task loading / metrics. In this repo the worked example is third_party/functional-welfare-axis/inspect_tasks/ (see the functional-welfare-axis skill).
---

# UK AISI Inspect (`inspect_ai`)

Practical notes for writing/running Inspect evals. Reference: https://inspect.aisi.org.uk.

## Mental model
- A **`Task`** = `dataset` (list of `Sample`) + `solver` (produces model output) +
  `scorer` (grades output → `Score`). Decorate a function with `@task` returning a `Task`.
- A **`Sample`** has `input`, `target`, `id`, `metadata` (+ choices/files/setup). The
  log viewer shows input, target, the model messages, the score, and a **metadata tab**
  (no per-field tooltips exist — document fields elsewhere). Group metrics by a metadata
  key with `grouped(metric, "key")`.
- Run: `inspect eval path/to/file.py --model <provider/model>`; task params via
  `-T name=value`; a specific task in a file via `file.py@task_name`.

## "Judge as model-under-test" pattern (LLM-judge / model-graded scoring)
When the thing being judged is precomputed text (not a fresh model rollout), put the
**judge** in the `--model` slot: a custom `@solver` renders the judge prompt from the
sample and calls `generate()`; the `@scorer` parses `state.output.completion`. Swapping
`--model` then swaps the judge backend. Sketch:

```python
@solver
def judge_solver(render):
    async def solve(state, generate):
        state.messages = [ChatMessageUser(content=render(state))]
        return await generate(state)
    return solve

@scorer(metrics=[mean(), stderr(), grouped(mean(), "factor")])
def my_scorer():
    async def score(state, target):
        v = parse(state.output.completion)
        return Score(value=float("nan") if v is None else v,
                     answer=str(v), metadata={"factor": state.metadata["factor"]})
    return score
```
`mockllm/model` is the no-real-model option for wiring tests (returns canned text).

## Metrics gotcha (important)
Inspect **excludes samples whose `Score.value` is a NaN float** from *every* metric
(counted as `unscored_samples`). So:
- Return `value=NaN` for parse failures → they're auto-dropped and the built-in
  `mean()`/`stderr()`/`grouped()` average over parsed only. Don't write a custom
  "nan-mean" or "parse-failure-rate" metric — the former is redundant, the latter can
  never see the failures.
- `value=0.0` is kept (not NaN) — fine for 0/1 rate scores.
- A metric returning a `Mapping` becomes one log metric per key (e.g. `grouped` →
  one entry per group + `all`; a label-distribution metric → one per label). Mapping
  values must be scalars (no nested dicts).
- Custom `@metric`: `def m(scores: list[SampleScore]) -> Value`. Read `s.score.value`,
  `s.score.metadata`, `s.sample_metadata`.

## Task-file loading gotcha
`inspect eval file.py` path-loads the file with **no package context** and does **not**
add its dir to `sys.path`. So **relative imports fail**. Fix in each entry task file:
```python
import sys, pathlib
_root = str(pathlib.Path(__file__).resolve().parent.parent)
if _root not in sys.path: sys.path.insert(0, _root)
from mypkg.helpers import ...   # absolute import now resolves
```
Helper modules (imported as package members, not passed to `inspect eval`) keep
relative imports.

## Providers & env (this repo)
- `vllm/<model>` — connect to a **running** vLLM OpenAI server via `VLLM_BASE_URL`
  (+ `VLLM_API_KEY`, defaults `"dummy"`) or `--model-base-url`. In server mode it does
  **not** import the `vllm` package — only `openai`. It imports `vllm` *only* if it has
  to start its own server (no base_url/port).
- `mistral/<model>` — `MISTRAL_API_KEY`. inspect_ai 0.3.x needs **`mistralai>=1.9.11,<2`**
  (v2 dropped `AudioChunk` → ImportError).
- `google/<model>` — `GOOGLE_API_KEY` (google-genai; also reads GEMINI_API_KEY).
- `openai-api/<service>/<model>` — generic OpenAI-compatible; reads `<SERVICE>_API_KEY`
  and `<SERVICE>_BASE_URL`. Drop-in alt to `vllm/` against the same endpoint.
- Inspect auto-loads `.env` from the working dir. `INSPECT_EVAL_MODEL` sets a default model.
- Per-call generation config: `Task(config=GenerateConfig(temperature=0, max_tokens=...,
  extra_body={...}))`. `extra_body` reaches OpenAI-compatible servers (e.g. vLLM accepts
  `extra_body={"chat_template_kwargs": {"enable_thinking": False}}`); strip it for
  Mistral/Google runs.

## VSCode "Inspect AI" extension
Uses the **Python extension's selected interpreter** — point it at the env that has
`inspect_ai` + the provider clients. Gives a task explorer, model picker, run/debug, and
the `.eval` log viewer (also opens logs produced by the CLI). `.eval` logs land in
`./logs` unless `--log-dir` is set.
