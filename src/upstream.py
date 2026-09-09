"""Access to the upstream `functional-welfare-axis` code without a package-name clash.

Both this repository and the submodule have a top-level `src` package, so putting the
submodule's *root* on `sys.path` would shadow our own `src`. We put the submodule's
`src/` directory on the path instead, which exposes its sub-packages (`maze`,
`concept_vector`, ...) as top-level names that collide with nothing here.

Only modules that are free of `src.`-rooted imports are re-exported below; everything
listed is used unmodified, per `AGENTS.md` ("It is ok though to import from
third_party/functional-welfare-axis if no customization is necessary").

Deliberately *not* re-exported:

- `pytorch_trainer.rollout.compute_reward` — charges `len(player_trajectory)` step
  penalties (16 for a 15-move episode) where the paper's Table 25 charges 15. See
  `src.maze.reward` for our replacement.
- `maze.inference.compute_reward` — same formula, plus a `goal_reward: 10.0` fallback
  when a run config carries no rewards block (the paper uses 20.0).
"""

from __future__ import annotations

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
UPSTREAM_SRC = REPO_ROOT / "third_party" / "functional-welfare-axis" / "src"


def _ensure_on_path() -> None:
    if not UPSTREAM_SRC.is_dir():
        raise RuntimeError(
            f"Upstream source not found at {UPSTREAM_SRC}. The submodule is probably "
            "not checked out; run `git submodule update --init --recursive`."
        )
    path = str(UPSTREAM_SRC)
    if path not in sys.path:
        sys.path.insert(0, path)


_ensure_on_path()

# ruff: noqa: E402  (imports must follow the sys.path manipulation above)
from maze.game import DIRECTIONS, Game, GameResult  # type: ignore[import-not-found]
from maze.maze import Maze, MazeGenerator  # type: ignore[import-not-found]
from maze.tiles import TileConfig  # type: ignore[import-not-found]

__all__ = [
    "DIRECTIONS",
    "Game",
    "GameResult",
    "Maze",
    "MazeGenerator",
    "TileConfig",
    "REPO_ROOT",
    "UPSTREAM_SRC",
    "activation_extraction",
    "hook_utils",
]


def hook_utils():
    """Lazily import `concept_vector.hook_utils` (pulls in torch)."""
    _ensure_on_path()
    from concept_vector import hook_utils as mod  # type: ignore[import-not-found]

    return mod


def activation_extraction():
    """Lazily import `concept_vector.activation_extraction` (pulls in torch, peft)."""
    _ensure_on_path()
    from concept_vector import activation_extraction as mod  # type: ignore[import-not-found]

    return mod
