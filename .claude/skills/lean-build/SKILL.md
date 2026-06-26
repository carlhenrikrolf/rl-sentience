---
name: lean-build
description: Build, navigate, and debug the RLSentience Lean 4 / Lake project (root lakefile, Mathlib pinned to v4.28.0 for Aristotle/harmonic.fun compatibility). Covers the project layout, the lib glob, the source/ ↔ RLSentience/ mapping, the harmonic.fun proof-import workflow, and fixes for the recurring build/editor errors: "unknown module prefix 'Mathlib'", "some modules have bad imports", ProofWidgets "not up-to-date", and the editor's "imports are out of date". Use whenever running `lake build`, debugging Lean import/toolchain/ProofWidgets errors, or pulling Aristotle proofs into the lib.
---

# RLSentience Lean / Lake build

The repo root `/Users/work/Git/rl-sentience/` **is** the Lake project root: `lakefile.toml`,
`lean-toolchain`, `lake-manifest.json`, and `.lake/` all live there. Open the **repo root** as
the VSCode workspace folder — not the `RLSentience/` subfolder (see error #1).

## Layout

- Library `RLSentience`, `srcDir = "."` (repo root), declared in [lakefile.toml](lakefile.toml) with:
  ```toml
  [[lean_lib]]
  name = "RLSentience"
  globs = ["RLSentience.+"]
  ```
  `RLSentience.+` globs the `RLSentience/` directory and all submodules. There is **no**
  `RLSentience.lean` root file — the `.+` glob is what makes that OK (see error #2).
- Sources: `RLSentience/Basic.lean`, `RLSentience/Tone/{Main,SubtractionGroup}.lean`,
  `RLSentience/AbelianTone/{Basic,Main}.lean`. Each module just does `import Mathlib`.

## Version pin — do NOT bump

- `lean-toolchain` = `leanprover/lean4:v4.28.0`; lakefile mathlib `rev = "v4.28.0"`.
- This is **deliberate**: v4.28.0 is the version compatible with the latest **Aristotle** prover on
  harmonic.fun, which generates the proofs. On v4.32.0-rc1 the brittle `convert; swap; exact` step in
  `SubtractionGroup.add_assoc` breaks with a type mismatch. Don't "upgrade to latest" without raising
  the tradeoff with the user.

## harmonic.fun / Aristotle workflow

- `source/` (git-tracked) holds downloaded Aristotle zips, each a **standalone** Lake project named
  `RequestProject` with its own lakefile (`globs = ["RequestProject.+"]`), `.lake/`, and
  `RequestProject/*.lean` proofs. These are **not** part of the root build.
- Mapping into the lib:
  - `RLSentience/Tone/`        ← `source/tone/original/RequestProject/`
  - `RLSentience/AbelianTone/` ← `source/tone/optional_abelian_optional_invertible/RequestProject/`
- To import a proof: copy the `.lean` files from a source `RequestProject/` into the right
  `RLSentience/<Subdir>/` folder. No module-prefix rewriting is needed — the files only
  `import Mathlib`, and their module name comes from the path under the lib. Proofs verified on
  Aristotle's v4.28.0 compile as-is here.

## Common errors and fixes

1. **`unknown module prefix 'Mathlib'`** (editor or `lean`) — the Lean server is anchored at the wrong
   project root (e.g. a stale server still rooted at the old `RLSentience/.lake`, or VSCode opened on
   the `RLSentience/` subfolder). Open the **repo root** as the workspace and run *Lean 4: Restart
   Server*. Mathlib + `.lake/packages` live at the repo root.

2. **`RLSentience: some modules have bad imports`** (from `lake build`) — the lib has no `globs`, so
   Lake defaults to building only a root module `RLSentience` (file `RLSentience.lean`, which doesn't
   exist). Fix: add `globs = ["RLSentience.+"]` to the `[[lean_lib]]` block.

3. **`ProofWidgets not up-to-date. Please run lake exe cache get`** (target `proofwidgets/widgetJsAll`)
   — appears after a toolchain/version swap. The ProofWidgets cloud-release ships a CI-baked
   `js/lake.trace`; after a swap Lake recomputes a different input trace, declares the prebuilt JS
   stale, and tries to npm-build — but Mathlib pins ProofWidgets `with errorOnBuild = "<that message>"`
   ([.lake/packages/mathlib/lakefile.lean:12](.lake/packages/mathlib/lakefile.lean#L12)), so it
   errors instead. `lake exe cache get` only fetches Mathlib oleans, not this. Fix — clean re-fetch so
   Lake re-clones ProofWidgets and writes a local-matching trace:
   ```
   rm -rf .lake/packages/proofwidgets
   lake build
   ```
   Last resort (only if the clean re-fetch still fails): npm is installed, so temporarily comment out
   the `errorOnBuild` guard in `.lake/packages/proofwidgets/lakefile.lean` (~line 74), `lake build`
   once to npm-build the JS, then restore it.

4. **Editor: "Imports are out of date and must be rebuilt; use the Restart File command"** — persists
   through *Restart Server* because the extension caches the toolchain at window load. After a
   `lean-toolchain` change, **Reload Window** (⌘⇧P → "Developer: Reload Window") or fully quit/reopen
   VSCode (⌘Q). If it still shows after a full restart, it's stale oleans: `lake clean && lake build`.

## Commands

- `lake build` — build the whole lib.
- `lake build RLSentience.Tone.SubtractionGroup` — build one module (fast way to surface a
  per-module error that `lake build`'s summary hides).
- `lake exe cache get` — fetch the Mathlib olean cache (needed after a fresh checkout or version
  change; needs network to GitHub/Azure).
- `lake clean` — remove the workspace's own build artifacts (keeps the Mathlib cache).
- macOS note: `timeout` is **not** installed by default — use `gtimeout` (coreutils) or omit it.
