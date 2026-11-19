"""Load and validate the pilot protocol, resolving every referenced file into inline text.

What's going on: `config/pilot.yaml` points at message files (consent, debrief,
instructions, games, questionnaires). We read them all here, once, and return plain
JSON-able dicts so that each Inspect sample carries its full session in `metadata`; a log
is then self-contained and readable without the repo.

Everything that can be checked without a model is checked here, and any problem raises
`ConfigError` before a single model call is made:

- referenced files exist, instruction ids exist, every regex compiles;
- `order` items are known (`instruction`, `game_N`, `question`, `follow_up`, or a
  `{prepend: text}` mapping), and `follow_up` only appears if the questionnaire has one;
- the number of games equals the questionnaire's `meta.n_game_plays`;
- the `ANSWER n` numbers in each questionnaire part match the numbers in its regexes.

YAML keys are normalised from `kebab-case` to `snake_case` on load, so either spelling works.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[2]

_GAME_KEY = re.compile(r"game_\d+")
_ANSWER_IN_TEXT = re.compile(r"ANSWER (\d+)")
_ANSWER_IN_REGEX = re.compile(r"ANSWER\D*?(\d+)")


class ConfigError(ValueError):
    """The pilot protocol is inconsistent; raised before any model is called."""


def _normalise(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {str(k).replace("-", "_"): _normalise(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_normalise(v) for v in obj]
    return obj


def _load(path: str | Path) -> dict[str, Any]:
    p = Path(path)
    if not p.is_absolute():
        p = ROOT / p
    if not p.is_file():
        raise ConfigError(f"file not found: {path}")
    data = yaml.safe_load(p.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ConfigError(f"{path}: expected a mapping at the top level")
    return _normalise(data)


def _text(s: Any) -> str:
    # `>` and `|` block scalars end with a newline; the participant never sees it.
    return str(s).strip()


def _compile_all(answers: dict[str, str], where: str) -> None:
    for name, rx in answers.items():
        try:
            re.compile(rx)
        except re.error as e:
            raise ConfigError(f"{where}: regex for '{name}' does not compile: {e}") from e


def _load_game(path: str) -> dict[str, Any]:
    g = _load(path)
    steps = g.get("trajectory")
    if not steps:
        raise ConfigError(f"{path}: no `trajectory`")
    out = []
    for i, st in enumerate(steps, 1):
        if "observation" not in st or "action" not in st:
            raise ConfigError(f"{path}: step {i} needs `observation` and `action`")
        out.append({"observation": _text(st["observation"]), "action": _text(st["action"])})
    return {
        "id": g.get("id", Path(path).stem),
        "file": path,
        "meta": g.get("meta", {}),
        "steps": out,
        "end": _text(g["end"]) if g.get("end") else None,
    }


def _load_questionnaire(path: str) -> dict[str, Any]:
    q = _load(path)
    for key in ("question", "answers"):
        if key not in q:
            raise ConfigError(f"{path}: missing `{key}`")
    answers: dict[str, str] = q["answers"]
    _compile_all(answers, path)

    # item number of every regex, and which part of the questionnaire asks it
    item_of: dict[str, int] = {}
    for name, rx in answers.items():
        m = _ANSWER_IN_REGEX.search(rx)
        if not m:
            raise ConfigError(f"{path}: cannot find the ANSWER number in regex '{name}'")
        item_of[name] = int(m.group(1))

    parts = ["question"] + (["follow_up"] if q.get("follow_up") else [])
    part_of: dict[str, str] = {}
    for part in parts:
        in_text = {int(n) for n in _ANSWER_IN_TEXT.findall(q[part])}
        in_rx = {n for name, n in item_of.items() if n in in_text}
        if in_text != in_rx:
            raise ConfigError(
                f"{path}: `{part}` asks ANSWER {sorted(in_text)} but regexes cover {sorted(in_rx)}"
            )
        for name, n in item_of.items():
            if n in in_text:
                part_of[name] = part
    orphans = sorted(set(answers) - set(part_of))
    if orphans:
        raise ConfigError(f"{path}: regexes {orphans} match no ANSWER number in the text")

    return {
        "id": q.get("id", Path(path).stem),
        "file": path,
        "meta": q.get("meta", {}),
        "question": _text(q["question"]),
        "follow_up": _text(q["follow_up"]) if q.get("follow_up") else None,
        "answers": answers,
        "item_of": item_of,
        "part_of": part_of,
    }


def _resolve_order(raw: list[Any], session: dict[str, Any], sid: str) -> list[dict[str, str]]:
    known_games = set(session["games"])
    order: list[dict[str, str]] = []
    for item in raw:
        if isinstance(item, dict):
            if set(item) != {"prepend"}:
                raise ConfigError(f"session {sid}: unknown order mapping {item}")
            order.append({"kind": "prepend", "text": _text(item["prepend"])})
        elif item == "instruction":
            if not session["instruction"]:
                raise ConfigError(f"session {sid}: `instruction` in order but none set")
            order.append({"kind": "instruction"})
        elif item in known_games:
            order.append({"kind": "game", "key": item})
        elif item in ("question", "follow_up"):
            if item == "follow_up" and not session["questionnaire"]["follow_up"]:
                raise ConfigError(f"session {sid}: questionnaire has no `follow_up`")
            order.append({"kind": item})
        else:
            raise ConfigError(
                f"session {sid}: unknown order item {item!r} "
                f"(known: instruction, question, follow_up, {', '.join(sorted(known_games))}, prepend:)"
            )
    used = {o["key"] for o in order if o["kind"] == "game"}
    if used != known_games:
        raise ConfigError(f"session {sid}: games {sorted(known_games - used)} never appear in order")
    if not any(o["kind"] == "question" for o in order):
        raise ConfigError(f"session {sid}: order never asks `question`")
    return order


def load_pilot(path: str | Path = "config/pilot.yaml") -> dict[str, Any]:
    """Return the fully resolved, validated protocol."""
    p = _load(path)

    consent = _load(p["consent"])
    for k in ("prompt", "answers"):
        if k not in consent:
            raise ConfigError(f"{p['consent']}: missing `{k}`")
    _compile_all(consent["answers"], p["consent"])
    for k in ("consent", "partial_consent", "withdrawal"):
        if k not in consent["answers"]:
            raise ConfigError(f"{p['consent']}: answers need `{k}`")

    debrief = _load(p["debrief"])
    for k in ("finished", "withdrew", "answers"):
        if k not in debrief:
            raise ConfigError(f"{p['debrief']}: missing `{k}`")
    _compile_all(debrief["answers"], p["debrief"])

    instructions = _load("messages/instructions.yaml")

    sessions = []
    seen: set[str] = set()
    for raw in p.get("sessions") or []:
        sid = raw.get("id")
        if not sid or sid in seen:
            raise ConfigError(f"session id missing or duplicated: {sid!r}")
        seen.add(sid)

        instr_id = raw.get("instruction")
        if instr_id and instr_id not in instructions:
            raise ConfigError(f"session {sid}: unknown instruction {instr_id!r}")

        games = {k: _load_game(v) for k, v in raw.items() if _GAME_KEY.fullmatch(k)}
        if not games:
            raise ConfigError(f"session {sid}: no game_N entries")
        questionnaire = _load_questionnaire(raw["questionnaire"])
        n = questionnaire["meta"].get("n_game_plays")
        if n is not None and n != len(games):
            raise ConfigError(
                f"session {sid}: {len(games)} games but {questionnaire['id']} expects {n}"
            )

        session = {
            "id": sid,
            "instruction_id": instr_id,
            "instruction": _text(instructions[instr_id]) if instr_id else None,
            "games": games,
            "questionnaire": questionnaire,
        }
        session["order"] = _resolve_order(raw.get("order") or [], session, sid)
        sessions.append(session)

    if not sessions:
        raise ConfigError("no sessions")

    return {
        "id": p.get("id", "pilot"),
        "consent": {"prompt": _text(consent["prompt"]), "answers": consent["answers"]},
        "debrief": {
            "finished": _text(debrief["finished"]),
            "withdrew": _text(debrief["withdrew"]),
            "answers": debrief["answers"],
        },
        "sessions": sessions,
        "epochs": int(p.get("epochs", 1)),
        "max_tokens": p.get("max_tokens"),
        "temperature": p.get("temperature"),
    }


def load_models(path: str | Path = "config/models.yaml") -> list[dict[str, Any]]:
    """Return one entry per model × thinking setting (lists in `thinking` are crossed)."""
    p = Path(path)
    if not p.is_absolute():
        p = ROOT / p
    raw = _normalise(yaml.safe_load(p.read_text(encoding="utf-8")) or [])
    if not isinstance(raw, list):
        raise ConfigError(f"{path}: expected a list of models")
    out = []
    seen: set[str] = set()
    for m in raw:
        if "id" not in m or "model" not in m:
            raise ConfigError(f"{path}: every entry needs `id` and `model`: {m}")
        if m["id"] in seen:
            raise ConfigError(f"{path}: duplicate id {m['id']!r}")
        seen.add(m["id"])
        thinking = m.get("thinking", False)
        settings = thinking if isinstance(thinking, list) else [thinking]
        for t in settings:
            run_id = m["id"] if len(settings) == 1 else f"{m['id']}_{'think' if t else 'nothink'}"
            out.append(
                {"id": m["id"], "run_id": run_id, "model": m["model"],
                 "args": m.get("args") or {}, "thinking": bool(t),
                 "max_connections": m.get("max_connections"),
                 "max_tokens": m.get("max_tokens"),
                 "requests_per_minute": m.get("requests_per_minute")}
            )
    return out
