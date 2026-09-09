# TODO

## Reproduction
- [x] Step-penalty off-by-one. compute_reward multiplies step_penalty by len(player_trajectory), which is initialised with the start position — so a 15-move episode incurs 16 penalties, −1.6 not −1.5. Worth pinning in the spec since it's exactly the sort of thing that makes numbers fail to match for opaque reasons.
- [ ] ~~The cohort comparison is a load-check, not validation. Line 38 says the base-vs-LoRA score comparison checks "that the LoRA does indeed work" — fine, but the base model has never seen the maze, so a gap is guaranteed and tells you only that the adapter is attached. It's worth saying so explicitly, because the paper's own results show Llama-3.1-8B never solves the maze (final reward −1.4) yet recruits as strongly as anything at −0.86. Maze competence is not a proxy for the phenomenon.~~

Solver — a custom @solver (no built-in fits; maze_solver is our name, not an Inspect primitive). Signature is async def solve(state: TaskState, generate: Generate) -> TaskState. Hold the Game in state.metadata, loop up to max_turns — render game.get_prompt() as a ChatMessageUser, await generate(state), parse N/E/S/W from state.output.completion, game.move(...), append the next turn; set state.completed = True on terminal. Wind messages come free via _pending_wind_message.

Not multiple_choice(), despite the four N/E/S/W options — docs/experiments/reproduction.md line 26 currently specifies "a multiple choice scorer running multiple turns", which Inspect cannot do. Per https://inspect.aisi.org.uk/solvers.html.md, that solver requires Sample.choices (fixed per sample; ours change every turn), requires Sample.target to be a capital letter and pairs only with the choice() scorer (we score cumulative reward, with no correct answer), is single-turn — it calls generate() internally once — and rewrites the prompt into its own A) … B) … template, which would break the Appendix K fidelity check below. The spec line needs revising by the user.

### Implementation follow-ups (from the first build of `src/`)

- [ ] **HIGH — no action masking in v1.** The paper constrains sampling to the four
  direction tokens with a `LogitsProcessor` (`DirectionLogitsProcessor` upstream).
  `src/maze/task.py` instead parses leniently and records `invalid_output` as a
  termination reason. This changes the reward distribution — an unparseable output ends
  the episode early rather than being resampled — so maze scores are not comparable to the
  paper's until it is added. Inspect route: `GenerateConfig(logit_bias=...)` with the four
  token ids, or `extra_body` against a vLLM server.
- [ ] **HIGH — verify the vector anchor's premise** before trusting
  `src/vectors/compare.py`: that the published `concept_vectors/qwen3-4b_step400` is the
  same run as the `qwen3-4b_faithful_step400` adapter. Its metadata says
  `checkpoint_path: runs/run2/global_step_400`. If the runs differ, a low cosine is
  uninformative.
- [ ] **LOW — sentiment judge is Gemini, not the paper's Qwen3-8B** (thinking disabled).
  The judge prompt is verbatim; the judge is not. Han et al. never validated theirs against
  humans either (Appendix E: 62.6% exact agreement with a second judge, ±1 87.6%,
  r = 0.83), so treat sentiment as a group-mean instrument.
- [ ] **LOW — `grouped(mean(), "cohort")` dropped from the maze scorer.** Cohort is a
  property of the model, not the sample, so within one eval run every sample shares it and
  the grouping is degenerate. The base-vs-LoRA comparison happens *across* logs, which is
  what `eval_set()` is for. `grouped` is still used in the sentiment scorer, where
  `category` genuinely varies within a run.
- [x] ~~**LOW — sandbox needs `~/.cache/uv`, `~/.cache/huggingface`, and
  `~/Library/Application Support/inspect_ai`** in `sandbox.filesystem.allowWrite`.~~ Done.
- [x] ~~`python -m src.run` is required instead of `inspect`.~~ Fixed: the project is now an
  installable package (`hatchling`, `package = true`) declaring
  `[project.entry-points.inspect_ai]`, which is how Inspect finds custom providers — and the
  only way the **VS Code extension** can, since it shells out to `inspect` itself. Inspect
  resolves `--model` before loading the task file, so importing the registry from a task is
  too late. `src/run.py` is kept only as a fallback for an uninstalled checkout.
- [x] ~~Extraction merges the adapter; evaluation does not.~~ Resolved: extraction now
  unwraps to `peft_model.base_model.model` instead of calling `merge_and_unload()`. That is a
  plain `Qwen3ForCausalLM` — satisfying upstream's `get_model_block_modules` assertion on
  `model.model.layers` — whose projections are still peft LoRA modules, so the adapter stays
  active. Both code paths now load the model the same way, and the merge's memory spike is
  gone.
- [ ] **MED — the whole extraction path is now ours, not upstream's.** Two forced moves:
  `concept_vector.extract_all.generate_trajectories` cannot be imported (it does
  `from src.maze.tiles import ...`, and the submodule's top-level package is also `src`, so it
  collides with this repo's irreducibly; its walk helpers also need pandas/pyarrow), and
  `activation_extraction.get_all_tile_activations` cannot run on Apple Silicon (it allocates
  accumulators as `float64` on `model.device`, which MPS rejects). So
  `src/vectors/trajectories.py` and `src/vectors/capture.py` reimplement both.
  Conventions were matched deliberately — final token is the direction letter with no
  `<|im_end|>`, 36 block-input layers, float64 accumulation, `(1, n_layers, d_model)` shape
  — and the shape now matches the published vectors exactly. **Neither has been
  cross-checked against upstream's numeric output**, which matters if the vector anchor
  disagrees. `src/upstream.py` is now used only for `Game`/`Maze`/`MazeGenerator`/`TileConfig`.
- [x] ~~Extraction crashed on MPS during weight loading.~~ Root cause: forcing `float16` on a
  bfloat16 checkpoint makes each load a cast, routing transformers' 4 loader threads through
  `copy_cast_kernel_mps` -> `MetalShaderLibrary::exec_unary_kernel`, which fills a
  non-thread-safe `std::unordered_set`. Fixed by defaulting `--dtype auto`; `--load-workers 1`
  added as a fallback. Verified on CPU only — **the MPS path is still unconfirmed.**


## Skills to write (low priority)

Two project-local skills. Deliberately *not* additions to `inspect-skills:*`, which come from
UK AISI, nor to the `huggingface-skills` marketplace.

- [ ] **`inspect-gotchas`** — our findings, distinct from AISI's own skills:
  - Custom model providers register only via `[project.entry-points.inspect_ai]` on an
    *installed* distribution. Inspect resolves `--model` before loading the task file, so
    importing a registry from the task is too late, and a CLI wrapper doesn't help the VS Code
    extension (it shells out to `inspect`).
  - NaN score filtering happens in `_eval/task/results.py`, not inside the metric. Calling
    `mean()` directly on NaN-containing scores returns NaN and looks like a doc error.
    `EvalScore.unscored_samples` / `scored_samples` are where it shows up.
  - `--task-config` takes YAML/JSON bound to `@task` params and does **not** merge multiple
    files; `INSPECT_EVAL_*` are environment variables and belong in `.env`.
  - `multiple_choice()` is single-turn, needs fixed `Sample.choices`, and pairs only with
    `choice()` — no good for a multi-turn environment.

- [ ] **`torch-mps-peft`** — local model loading on Apple Silicon. Checked against the
  `huggingface-skills` marketplace: `hf-cli` covers download/cache, `hf-mem` covers memory
  estimation, `huggingface-local-models` covers llama.cpp/GGUF — none covers the
  transformers+torch+MPS path below.
  - MPS has no float64. Anything allocating accumulators as `float64` on `model.device`
    fails; accumulate on CPU instead.
  - Forcing a dtype different from the checkpoint's makes loading a *cast*, which races
    transformers' 4-thread loader inside torch's Metal shader cache → SIGSEGV with no Python
    traceback. Use `dtype="auto"`; `core_model_loading.GLOBAL_WORKERS` is the only lever and
    has no env var.
  - `torch.backends.mps.is_available()` can return False under a sandbox with a misleading
    "requires macOS 14.0+" message; everything then silently runs on CPU.
  - **UNRESOLVED**: on MPS the three class means came out bit-identical, zeroing every
    difference vector, while CPU with identical parameters gave distinct means. See the
    entry below.
  - PEFT: adapter-only repos need `subfolder=`; `peft_model.base_model.model` unwraps to a
    plain `Qwen3ForCausalLM` with LoRA still active (for code asserting `model.model.layers`)
    without paying for `merge_and_unload()`.
  - MLX-format models (`mlx-community/*`) cannot be loaded by transformers or peft at all —
    separate artifact, not a substitute for the original weights.

- [ ] **HIGH — MPS produces bit-identical class means.** `vectors/qwen3-4b_faithful_step400`
  from the first real run has all three `mean_diff.pt` exactly zero, because the LAVA/GOAL/PATH
  means were identical. CPU at the same `maze_size=100` gives 946.2 / 961.4 / 921.6. Run
  `tmp_mps_check.py` to see whether MPS returns identical hidden states for different inputs.
  `summary.json` now records `mean_norms` and `max_abs_diff_between_class_means` so this is
  visible without re-deriving it.
