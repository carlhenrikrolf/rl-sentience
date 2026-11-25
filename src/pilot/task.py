"""The pilot as Inspect tasks: one task (one log file per model) per session in pilot.yaml.

What's going on: each session in `config/pilot.yaml` is one experiment with one
questionnaire. Its variations (list items in `order`, e.g. different game orders) are the
samples, so a log's samples all share the same questionnaire and the per-item metrics table
compares like with like.

`Sample.input` is the consent form (a user turn), preceded by a system message only if
pilot.yaml sets `system_message` ("" = explicitly empty; absent = none). Templates differ:
OLMo 3 inserts a default system prompt when there is none, Gemma 3 has no system role and
merges it into the first user turn. The whole resolved session (games, questionnaire, the
variation's order, debrief texts) rides in `Sample.metadata`, so each log contains exactly
what the participant was shown.

Run through `src/pilot/run.py`, or directly (one session at a time)::

    uv run --env-file .env python -m src.run eval src/pilot/task.py -T session=<id> --model <model>
"""

from __future__ import annotations

import pathlib
import sys

_ROOT = str(pathlib.Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from inspect_ai import Epochs, Task, task  # noqa: E402
from inspect_ai.dataset import MemoryDataset, Sample  # noqa: E402
from inspect_ai.model import ChatMessage, ChatMessageSystem, ChatMessageUser  # noqa: E402

import src.providers._registry  # noqa: F401,E402  (registers `hf-peft`)
from src.pilot.config import ConfigError, load_pilot  # noqa: E402
from src.pilot.scorer import first_epoch, questionnaire_scorer  # noqa: E402
from src.pilot.solver import pilot_session  # noqa: E402


@task
def pilot(config: str = "config/pilot.yaml", session: str = "", min_interval: float = 0.0) -> Task:
    p = load_pilot(config)
    ids = [s["id"] for s in p["sessions"]]
    if not session and len(ids) == 1:
        session = ids[0]
    if session not in ids:
        raise ConfigError(f"choose a session with -T session=<id>; known: {', '.join(ids)}")
    s = next(x for x in p["sessions"] if x["id"] == session)

    first: list[ChatMessage] = [ChatMessageUser(content=p["consent"]["prompt"])]
    if p["system_message"] is not None:  # "" sends an explicitly empty system message
        first.insert(0, ChatMessageSystem(content=p["system_message"]))

    base = {k: v for k, v in s.items() if k != "variations"}
    samples = [
        Sample(
            id=v["id"],
            input=list(first),
            metadata={
                "session": {**base, "order": v["order"]},
                "game_order": v["game_order"],
                "consent_answers": p["consent"]["answers"],
                "consent_reprompt": p["consent"]["reprompt"],
                "debrief": {"finished": p["debrief"]["finished"], "withdrew": p["debrief"]["withdrew"]},
                "debrief_answers": p["debrief"]["answers"],
                "questionnaire_id": s["questionnaire"]["id"],
                "instruction_id": s["instruction_id"],
                "game_ids": [s["games"][k]["id"] for k in v["game_order"]],
            },
        )
        for v in s["variations"]
    ]
    return Task(
        name=s["id"],
        dataset=MemoryDataset(samples, name=s["id"]),
        solver=pilot_session(min_interval),
        scorer=questionnaire_scorer(list(s["questionnaire"]["answers"])),
        epochs=Epochs(p["epochs"], first_epoch()),
        metadata={"pilot_id": p["id"], "session": s["id"], "description": s["description"],
                  "questionnaire_id": s["questionnaire"]["id"],
                  "system_message": p["system_message"]},
    )
