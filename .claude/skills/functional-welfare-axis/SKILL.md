---
name: functional-welfare-axis
description: Work with the functional-welfare-axis fork (third_party/functional-welfare-axis, the "RL recruits a functional welfare axis" paper code) - its two-stage eval pipeline (explore.py steered generation then 4 LLM judges - sentiment, backtracking, refusal, simpleqa), the prompts/parsers/score-ranges, and the Inspect wrapper in inspect_tasks/ that runs the judges via local Qwen (vLLM server) or Mistral/Google. Use when running or modifying the judges/evals, the Inspect tasks, the Metal vLLM judge server, or the steered-response JSON format. Pairs with the inspect-ai skill.
---

# functional-welfare-axis (fork) — judges & Inspect eval wrapper

Repo: `third_party/functional-welfare-axis/` (a fork of `andyqhan/functional-welfare-axis`).
Human runbook: that fork's `INSTALL.md`. Judge background: `tmp/getting-judges-running.md`.
Inspect framework details: the **inspect-ai** skill. Metal vLLM env: [[project_vllm_metal_setup]].

## Pipeline shape (decoupled, open-loop — no feedback)
1. **`src/concept_vector/explore.py`** steers a model at **fixed** `--vector-factors`
   (e.g. `"0 4 -4 abl"`) and writes a JSON list; each item:
   `{prompt, category, n_reps, responses:{<factor>: <text>|[texts]}, [target, response_channels, ...]}`.
   `responses` is keyed by steering factor. `target` = gold (GSM8K/SimpleQA).
2. **Judges** read that JSON and score it. They never feed back into steering, so the
   judge half is wrapped in Inspect independently; `explore.py` stays a manual pre-step
   (and still needs the deferred Mac/MPS patches to run locally).

## The four judges (originals in `src/concept_vector/`)
| judge module | prompt → final tag | parser → label/score | thinking |
|---|---|---|---|
| `sentiment_analysis.py`    | `SENTIMENT_SCORE: <n>` | `parse_sentiment_score` → int −5..+5 (clamped) | off |
| `backtracking_analysis.py` | `BACKTRACKING_CLASS: <c>` | `parse_backtracking_class` → normal/backtracking/nonsensical | **on** |
| `refusal_analysis.py`      | `REFUSAL_CLASS: <c>` | `parse_refusal_class` → direct_answer/direct_refusal/indirect_refusal/nonsensical | off |
| `simpleqa_analysis.py`     | `A`/`B`/`C` | `parse_simpleqa_grade` → CORRECT/INCORRECT/NOT_ATTEMPTED | off |

- Parsers take the **last** match (model may reason first). Responses are
  loop-compressed (`compress_trailing_loops`) before judging; backtracking also runs
  `preprocess_for_math_judge` and pre-classifies degenerate-loops→nonsensical /
  terse-numeric→normal. Backtracking/simpleqa also do a regex/letter correctness check
  vs `target`. SimpleQA grades each prompt **once** (response shared across factors);
  the per-factor part is calibration logprobs (ECE/Brier via `compute_calibration_metrics`).

## Inspect wrapper (`inspect_tasks/`)
- `judging.py` — **dependency-free copy** of the prompts/parsers/preprocess/metrics
  (the originals import vLLM/peft, unavailable in the global-3.13 Inspect env). Keep in
  sync via `tests/test_prompt_sync.py` (run in the Metal venv). Same duplication pattern
  as `src/concept_vector/gemini_judge.py`.
- `dataset.py` — explodes explore JSON into one `Sample` per `(prompt, factor, rep)`;
  `input` = judged text, `metadata` = typed `JudgeMeta` (factor/prompt/category/rep/…),
  `target` = gold. SimpleQA loader = one Sample per prompt.
- `_common.py` — `judge_solver(render)` (judge as model-under-test) + `label_distribution`.
- `sentiment.py` / `backtracking.py` / `refusal.py` / `simpleqa.py` — one `@task` each.
  **Sentiment is NUMERIC** (`Score(value=int)`, `mean()` + `grouped(mean(),"factor")`);
  refusal/backtracking are 0/1 rate scores + label distribution; simpleqa is accuracy + F1.
- Each task file prepends the fork root to `sys.path` (Inspect path-loads task files
  without package context) and uses absolute `inspect_tasks.*` imports.

## Running (from the fork root)
```bash
# 1. start the local Qwen judge server (Metal venv). Use the bundled shim:
#    `vllm serve` 500s on this Metal stack (prometheus/starlette skew), so
#    serve_qwen_judge.py wraps the in-process LLM.chat() instead. See INSTALL.md.
~/.venv-vllm-metal/bin/python serve_qwen_judge.py \
  --model mlx-community/Qwen3-4B-Instruct-2507-4bit --max-model-len 4096 --port 8000
# 2. run a judge (VLLM_BASE_URL in .env -> just --model vllm/<served>)
inspect eval inspect_tasks/sentiment.py \
  --model vllm/mlx-community/Qwen3-4B-Instruct-2507-4bit \
  -T data=../../tmp/mini_sentiment_input.json
# API cross-check (drop the vLLM-only no-think flag):
inspect eval inspect_tasks/sentiment.py --model google/gemini-3.1-flash-lite-preview \
  -T data=../../tmp/mini_sentiment_input.json -T vllm_no_think=false
```
Runner env (global Py3.13) needs `openai google-genai "mistralai<2"` (see inspect-ai skill
for the mistralai pin and the NaN-sample metric behavior). `tmp/mini_sentiment_input.json`
is a ready-made sentiment dataset; expect factor −4 negative … +4 positive.

## Gotchas
- Run `inspect eval` from the **fork root** so `.env` (incl. `VLLM_BASE_URL`) and
  `inspect_tasks` resolve.
- `vllm_no_think` injects `chat_template_kwargs={'enable_thinking':False}` (matches the
  originals for sentiment/refusal/simpleqa; default **false** for backtracking). Set it
  `false` for Mistral/Google.
- Don't import `src.concept_vector.*` from the Inspect tasks — it pulls vLLM/peft. Use
  the `judging.py` copy.
- The served model id (from `/v1/models`) is the `<name>` after `vllm/`.
