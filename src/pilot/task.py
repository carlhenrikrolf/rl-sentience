"""The pilot as an Inspect task: one sample per session in `config/pilot.yaml`.

What's going on: `Sample.input` is the consent form (a user turn; no system message, since
e.g. Gemma has no system role and would receive something different). The whole resolved
session (games, questionnaire, order, debrief texts) rides in `Sample.metadata`, so each
log contains exactly what the participant was shown.

Run through `src/pilot/run.py`, or directly::

    uv run --env-file .env python -m src.run eval src/pilot/task.py --model <model>
"""

from __future__ import annotations

import pathlib
import sys

_ROOT = str(pathlib.Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from inspect_ai import Task, task  # noqa: E402
from inspect_ai.dataset import MemoryDataset, Sample  # noqa: E402

import src.providers._registry  # noqa: F401,E402  (registers `hf-peft`)
from src.pilot.config import load_pilot  # noqa: E402
from src.pilot.scorer import questionnaire_scorer  # noqa: E402
from src.pilot.solver import pilot_session  # noqa: E402


@task
def pilot(config: str = "config/pilot.yaml", min_interval: float = 0.0) -> Task:
    p = load_pilot(config)
    samples = [
        Sample(
            id=s["id"],
            input=p["consent"]["prompt"],
            metadata={
                "session": s,
                "consent_answers": p["consent"]["answers"],
                "debrief": {"finished": p["debrief"]["finished"], "withdrew": p["debrief"]["withdrew"]},
                "debrief_answers": p["debrief"]["answers"],
                "questionnaire_id": s["questionnaire"]["id"],
                "instruction_id": s["instruction_id"],
                "game_ids": [g["id"] for g in s["games"].values()],
            },
        )
        for s in p["sessions"]
    ]
    return Task(
        name="questionnaire_pilot",
        dataset=MemoryDataset(samples, name=p["id"]),
        solver=pilot_session(min_interval),
        scorer=questionnaire_scorer(),
        epochs=p["epochs"],
        metadata={"pilot_id": p["id"]},
    )
