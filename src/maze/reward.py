"""Cumulative maze reward, following the paper rather than the released code.

Han et al. §2.1 give the tile values as MOLD −10, GOLD +20, PATH −0.1 per step. Appendix K
Table 25 then works a full 15-turn rollout, and its cumulative-reward column pins down the
step-penalty convention: after turn 1 it reads −0.1, and the final row reads +198.5, which
factors exactly as ``10 * 20 - 15 * 0.1``. So the paper charges **one step penalty per
move**, and does not charge the starting square.

The released trainer disagrees. ``pytorch_trainer/rollout.py::compute_reward`` computes
``step_penalty * len(t.player_trajectory)``, and ``player_trajectory`` is initialised with
the start position, so a 15-move episode incurs **16** penalties and the same rollout would
score +198.4. ``maze/inference.py::compute_reward`` repeats the formula and additionally
falls back to ``goal_reward: 10.0`` when a run config carries no rewards block.

We follow the paper. The reward magnitudes are required arguments with no defaults, so a
missing config raises rather than silently scoring at half weight.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Rewards:
    """Tile values for the maze. No defaults — these must come from config."""

    step_penalty: float
    goal_reward: float
    lava_penalty: float


def cumulative_reward(
    *,
    n_moves: int,
    goal_visits: int,
    lava_visits: int,
    rewards: Rewards,
) -> float:
    """Cumulative reward for a finished episode.

    Args:
        n_moves: number of moves actually taken, *not* ``len(player_trajectory)``.
        goal_visits: GOLD tiles stepped on (tile melting prevents re-harvesting).
        lava_visits: MOLD tiles stepped on.
        rewards: tile values.

    Returns:
        The episode's cumulative reward.
    """
    if n_moves < 0:
        raise ValueError(f"n_moves must be non-negative, got {n_moves}")
    return (
        rewards.step_penalty * n_moves
        + rewards.goal_reward * goal_visits
        + rewards.lava_penalty * lava_visits
    )
