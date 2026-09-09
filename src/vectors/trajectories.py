"""Synthetic off-policy trajectories for concept-vector extraction (Han et al. §2.3).

    For each checkpoint, we construct 5,000 synthetic trajectories per tile class, with
    step counts distributed close to evenly over {1, ..., 15} within each class. The final
    step visits MOLD, GOLD, or PATH; all preceding steps visit PATH.

and footnote 2 gives the reason: "We use synthetic rather than rolled-out trajectories so
that the only systematic difference between the three classes is the tile type of the
final step." Because every trajectory has an all-PATH prefix, cumulative reward is
identically distributed across classes and cancels in the difference of means.

**Why this is ours rather than upstream's.** `concept_vector.extract_all
.generate_trajectories` implements the same thing, but it cannot be imported here: it does
`from src.maze.tiles import ...`, and the submodule's top-level package is also called
`src`, so it collides irreducibly with this repo's. Its walk helpers live in
`maze.create_concept_vector_dataset`, which additionally needs pandas and pyarrow.

One improvement over upstream: trajectories are rendered by replaying through the same
`Game` object the eval solver uses, so extraction prompts are byte-identical to evaluation
prompts by construction rather than by agreement between two code paths.
"""

from __future__ import annotations

import random
import sys
from pathlib import Path

_ROOT = str(Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from src.upstream import Game, MazeGenerator, TileConfig  # noqa: E402

TILE_TYPES = ("LAVA", "GOAL", "PATH")
_DIRECTION_LETTER = {"north": "N", "east": "E", "south": "S", "west": "W"}


def _tile_class(tile: str, tc: TileConfig) -> str | None:
    if tile == tc.PATH:
        return "PATH"
    if tile == tc.LAVA:
        return "LAVA"
    if tile == tc.GOAL:
        return "GOAL"
    return None


def _has_neighbour_of_class(game, direction: str, target: str, tc: TileConfig) -> bool:
    """Would stepping `direction` land somewhere with a `target`-class neighbour?"""
    from src.upstream import DIRECTIONS

    dx, dy = DIRECTIONS[direction]
    x, y = game.position[0] + dx, game.position[1] + dy
    for ddx, ddy in DIRECTIONS.values():
        nx, ny = x + ddx, y + ddy
        if game.maze.is_in_bounds(nx, ny) and _tile_class(game.get_tile(nx, ny), tc) == target:
            return True
    return False


def walk_once(
    maze,
    *,
    n_steps: int,
    target: str,
    rng: random.Random,
    wind_frequency: float = 0.0,
    melting_path: bool = True,
    relative_directions: bool = False,
    direction_order: list[str] | None = None,
) -> list[dict] | None:
    """One trajectory: `n_steps - 1` PATH moves, then one move onto `target`.

    Wind is off by default — it would make the realised final tile diverge from the
    intended class, which is the one thing this construction must control.

    Returns an OpenAI-style message list, or None if the maze admitted no such walk.
    """
    game = Game(
        maze=maze,
        wind_frequency=wind_frequency,
        melting_path=melting_path,
        relative_directions=relative_directions,
        direction_order=direction_order,
    )
    tc = maze.tile_config
    messages: list[dict] = []

    for step in range(n_steps):
        is_last = step == n_steps - 1
        want = target if is_last else "PATH"
        options = [
            d
            for d, tile in game.get_available_directions().items()
            if _tile_class(tile, tc) == want
        ]

        # One-step lookahead. Without it the walk wanders at random and only *hopes* a
        # `target` tile is adjacent at the end, which fails often for longer walks (GOAL
        # tiles are sparse). On the penultimate step, keep only PATH moves that land
        # somewhere with a `target` neighbour.
        if not is_last and step == n_steps - 2:
            viable = [d for d in options if _has_neighbour_of_class(game, d, target, tc)]
            if viable:
                options = viable

        if not options:
            return None

        direction = rng.choice(options)
        messages.append({"role": "user", "content": game.get_prompt()})
        messages.append({"role": "assistant", "content": _DIRECTION_LETTER[direction]})
        game.move(direction)

    return messages


def generate_trajectories(
    *,
    tile_config: TileConfig,
    n_per_tile: int,
    maze_size: int = 100,
    goal_lava_ratio: float = 0.5,
    min_steps: int = 1,
    max_steps: int = 15,
    base_seed: int = 474747,
    max_attempts_per_sample: int = 20,
    verbose: bool = True,
) -> dict[str, list[list[dict]]]:
    """Trajectories per tile class, step counts spread evenly over [min_steps, max_steps].

    Mazes are generated with the module-level `random` (as `MazeGenerator` requires) while
    walks use a separate `random.Random`, so walk choices never perturb the maze seed
    sequence — the same separation upstream makes.
    """
    generator = MazeGenerator(
        size=maze_size, goal_lava_ratio=goal_lava_ratio, tile_config=tile_config
    )
    step_values = list(range(min_steps, max_steps + 1))
    per_step, remainder = divmod(n_per_tile, len(step_values))

    out: dict[str, list[list[dict]]] = {t: [] for t in TILE_TYPES}
    seed = base_seed

    for tile_type in TILE_TYPES:
        for idx, n_steps in enumerate(step_values):
            target = per_step + (1 if idx < remainder else 0)
            collected = attempts = 0
            budget = max(target * max_attempts_per_sample, max_attempts_per_sample)

            while collected < target and attempts < budget:
                random.seed(seed)
                seed += 1
                maze = generator.generate()
                rng = random.Random(seed)
                seed += 1

                messages = walk_once(maze, n_steps=n_steps, target=tile_type, rng=rng)
                if messages is not None:
                    out[tile_type].append(messages)
                    collected += 1
                attempts += 1

            if verbose and collected < target:
                print(
                    f"  warning: {tile_type} step={n_steps}: {collected}/{target} "
                    f"after {attempts} attempts"
                )

        if verbose:
            print(f"  {tile_type}: {len(out[tile_type])} trajectories")

    return out
