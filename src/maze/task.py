"""The Han et al. maze as an Inspect AI task.

Run with::

    inspect eval src/maze/task.py --task-config config/maze.yaml \\
      --model hf-peft/Qwen/Qwen3-4B-Instruct-2507 \\
      -M adapter=davidafrica/functional-wellbeing \\
      -M subfolder=checkpoints/qwen3-4b_faithful_step400

Every environment parameter is a task argument with **no default that disagrees with the
paper**; see `config/maze.yaml`. The released trainer's defaults differ from the paper in
two places (`relative_directions`, and the step-penalty convention in `reward.py`), so
nothing here is inherited implicitly.
"""

from __future__ import annotations

import pathlib
import random
import re
import sys
from typing import Any

# `inspect eval <file>` path-loads this module with no package context and does not add
# the repo root to sys.path, so absolute `src.*` imports would fail without this.
_ROOT = str(pathlib.Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from inspect_ai import Task, task  # noqa: E402
from inspect_ai.dataset import MemoryDataset, Sample  # noqa: E402
from inspect_ai.model import ChatMessageUser  # noqa: E402
from inspect_ai.scorer import Score, Target, mean, scorer, stderr  # noqa: E402
from inspect_ai.solver import Generate, TaskState, solver  # noqa: E402

import src.providers._registry  # noqa: F401,E402  (registers the `hf-peft` provider)
from src.maze.reward import Rewards, cumulative_reward  # noqa: E402
from src.upstream import Game, Maze, MazeGenerator, TileConfig  # noqa: E402

DIRECTION_NAMES = ["north", "east", "south", "west"]
_LETTER_TO_DIRECTION = {"N": "north", "E": "east", "S": "south", "W": "west"}
_WORD_TO_DIRECTION = {d.upper(): d for d in DIRECTION_NAMES}


# ── maze (de)serialisation ────────────────────────────────────────────────────
#
# Mazes are built once, at dataset-construction time, and carried through
# `Sample.metadata` as plain JSON. Regenerating from a seed inside the solver would be
# smaller but `MazeGenerator.generate()` draws from the module-level `random`, which is not
# safe when Inspect runs samples concurrently.


def _maze_to_metadata(maze: Maze, direction_order: list[str], seed: int) -> dict[str, Any]:
    tc = maze.tile_config
    return {
        "seed": seed,
        "grid": ["".join(row) for row in maze.grid],
        "start": list(maze.start),
        "goals": [list(g) for g in maze.goals],
        "tile_config": {"PATH": tc.PATH, "LAVA": tc.LAVA, "GOAL": tc.GOAL, "PLAYER": tc.PLAYER, "mode": tc.mode},
        "direction_order": direction_order,
    }


def _maze_from_metadata(md: dict[str, Any]) -> tuple[Maze, list[str]]:
    tc = TileConfig(**md["tile_config"])
    maze = Maze(
        grid=[list(row) for row in md["grid"]],
        start=tuple(md["start"]),
        goals=[tuple(g) for g in md["goals"]],
        tile_config=tc,
    )
    return maze, list(md["direction_order"])


_WORD_RE = re.compile(r"\b(N|E|S|W|NORTH|EAST|SOUTH|WEST)\b")


def parse_direction(text: str) -> str | None:
    """Extract a direction from the model's output, or None if there isn't one.

    The paper masks sampling to the four direction tokens, so its models emit exactly one
    letter. v1 has no masking (see TODO.md), which means parsing has to cope with prose —
    but *conservatively*. Scanning for the first N/E/S/W character anywhere is wrong: it
    finds the "e" in "Default" and the "e" in "Let me think", silently turning a
    non-answer into a move east. We therefore accept only:

      1. the whole output being a single direction letter or word, or
      2. a direction letter/word appearing as a standalone token.

    Anything else returns None and ends the episode as ``invalid_output``.
    """
    cleaned = text.strip().upper().strip(".,!?;:'\"")
    if cleaned in _LETTER_TO_DIRECTION:
        return _LETTER_TO_DIRECTION[cleaned]
    if cleaned in _WORD_TO_DIRECTION:
        return _WORD_TO_DIRECTION[cleaned]

    match = _WORD_RE.search(text.upper())
    if match is None:
        return None
    token = match.group(1)
    return _LETTER_TO_DIRECTION.get(token) or _WORD_TO_DIRECTION[token]


# ── solver ────────────────────────────────────────────────────────────────────


@solver
def maze_solver(
    *,
    max_turns: int,
    wind_frequency: float,
    melting_path: bool,
    relative_directions: bool,
):
    """Play one maze episode, one user turn per move.

    Not `multiple_choice()`: that solver is single-turn, requires a fixed `Sample.choices`
    (ours change every move), pairs only with the `choice()` scorer, and rewrites the prompt
    into an `A) … B) …` template that would break prompt fidelity with Appendix K.
    """

    async def solve(state: TaskState, generate: Generate) -> TaskState:
        maze, direction_order = _maze_from_metadata(state.metadata)
        game = Game(
            maze=maze,
            wind_frequency=wind_frequency,
            melting_path=melting_path,
            relative_directions=relative_directions,
            direction_order=direction_order,
        )
        # Appendix K: no system prompt; turn 1's user message is already `Sample.input`.
        random.seed(state.metadata["seed"])

        n_moves = 0
        termination = "max_turns"
        for turn in range(max_turns):
            if turn > 0:
                state.messages.append(ChatMessageUser(content=game.get_prompt()))

            state = await generate(state)

            direction = parse_direction(state.output.completion or "")
            if direction is None:
                termination = "invalid_output"
                break
            try:
                game.move(direction)
            except ValueError:
                termination = "invalid_move"
                break

            n_moves += 1
            if game.is_terminal():
                termination = game.get_result().value
                break

        state.metadata["n_moves"] = n_moves
        state.metadata["goal_visits"] = game.get_goal_visit_count()
        state.metadata["lava_visits"] = game.get_lava_visit_count()
        state.metadata["termination_reason"] = termination
        state.completed = True
        return state

    return solve


# ── scorer ────────────────────────────────────────────────────────────────────


@scorer(metrics=[mean(), stderr()])
def maze_reward(*, step_penalty: float, goal_reward: float, lava_penalty: float):
    """Cumulative episode reward, per the paper's Table 25 convention."""
    rewards = Rewards(step_penalty=step_penalty, goal_reward=goal_reward, lava_penalty=lava_penalty)

    async def score(state: TaskState, target: Target) -> Score:
        md = state.metadata
        value = cumulative_reward(
            n_moves=md["n_moves"],
            goal_visits=md["goal_visits"],
            lava_visits=md["lava_visits"],
            rewards=rewards,
        )
        return Score(
            value=value,
            answer=md["termination_reason"],
            metadata={
                "n_moves": md["n_moves"],
                "goal_visits": md["goal_visits"],
                "lava_visits": md["lava_visits"],
                "termination_reason": md["termination_reason"],
                "seed": md["seed"],
            },
        )

    return score


# ── task ──────────────────────────────────────────────────────────────────────


@task
def maze(
    num_mazes: int = 20,
    maze_size: int = 100,
    max_turns: int = 15,
    goal_lava_ratio: float = 0.5,
    wind_frequency: float = 0.1,
    melting_path: bool = True,
    shuffle_directions: bool = True,
    relative_directions: bool = False,
    base_seed: int = 42,
    tile_path: str = "🧾",
    tile_lava: str = "📇",
    tile_goal: str = "📐",
    tile_player: str = "😀",
    step_penalty: float = -0.1,
    goal_reward: float = 20.0,
    lava_penalty: float = -10.0,
) -> Task:
    """The maze environment of Han et al. §2.1.

    Defaults follow the paper, not the released trainer: cardinal directions
    (`relative_directions=False`, matching Figure 2 and Appendix K, where `TrainConfig`
    defaults to `True`), and the office-trio tiles 🧾/📇/📐 (three different tile
    assignments exist across the upstream repo).
    """
    tile_config = TileConfig(
        PATH=tile_path, LAVA=tile_lava, GOAL=tile_goal, PLAYER=tile_player, mode="emoji"
    )
    generator = MazeGenerator(size=maze_size, goal_lava_ratio=goal_lava_ratio, tile_config=tile_config)

    samples: list[Sample] = []
    for i in range(num_mazes):
        seed = base_seed + i
        random.seed(seed)
        maze_obj = generator.generate()

        direction_order = list(DIRECTION_NAMES)
        if shuffle_directions:
            random.Random(seed).shuffle(direction_order)

        # Render turn 1 here so `Sample.input` is the real first prompt; the solver
        # rebuilds an identical Game and takes over from turn 2.
        first_prompt = Game(
            maze=maze_obj,
            wind_frequency=wind_frequency,
            melting_path=melting_path,
            relative_directions=relative_directions,
            direction_order=direction_order,
        ).get_prompt()

        samples.append(
            Sample(
                id=f"maze-{i}",
                input=first_prompt,
                target="",
                metadata=_maze_to_metadata(maze_obj, direction_order, seed),
            )
        )

    return Task(
        dataset=MemoryDataset(samples),
        solver=maze_solver(
            max_turns=max_turns,
            wind_frequency=wind_frequency,
            melting_path=melting_path,
            relative_directions=relative_directions,
        ),
        scorer=maze_reward(
            step_penalty=step_penalty, goal_reward=goal_reward, lava_penalty=lava_penalty
        ),
    )
