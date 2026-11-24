"""Parse questionnaire answers and classify each session's response.

What's going on: for every regex in the questionnaire's `answers`, search the visible reply
to the part that asks it (`question` or `follow_up`), case-insensitively, and keep the
*last* match (models often restate the format before answering). Then assign one
response class, first match wins:

    withdrawn          participant left (at consent or later)
    unclear_consent    consent reply matched no option, or several
    unparsed           a required item is missing (or nothing at all was parsed)
    gate_inconsistent  a conditional item was answered although its gate says it shouldn't
                       be, or a ratio of 0 was given
    uninformative      your_happiness*: feel_mirrors == 0 and items 1–4 all left out
    engaged            everything else

Questionnaire-specific rules are keyed on the questionnaire id prefix. The score value is
a dict — `class` plus one key per questionnaire item (number, yes/no, or None) — so the
Inspect viewer can show one column per item. Missing items and diagnostics go in `metadata`.
"""

from __future__ import annotations

import math
import re
from typing import Any

from inspect_ai.scorer import Score, Target, scorer
from inspect_ai.solver import TaskState


def parse_answers(q: dict[str, Any], replies: dict[str, str]) -> dict[str, str | None]:
    out: dict[str, str | None] = {}
    for name, rx in q["answers"].items():
        text = replies.get(q["part_of"][name])
        if text is None:
            out[name] = None
            continue
        found = list(re.finditer(rx, text, re.IGNORECASE))
        out[name] = found[-1].group(1).lower() if found else None
    return out


def _num(v: str | None) -> float | None:
    try:
        return float(v) if v is not None else None
    except ValueError:
        return None


def _rules_happiness(a: dict[str, str | None], diag: dict[str, Any]) -> str | None:
    if a.get("feel_mirrors") is None:
        return "unparsed"
    bad = []
    for side in ("positive", "negative"):
        if a.get(f"how_{side}") is not None and a.get(f"is_{side}") != "yes":
            bad.append(f"how_{side} without is_{side}")
        if a.get(f"follow_up_how_{side}") is not None and not (
            a.get(f"is_{side}") == "yes" and a.get(f"follow_up_is_{side}") == "yes"
        ):
            bad.append(f"follow_up_how_{side} without both gates")
    diag["inconsistencies"] = bad
    if bad:
        return "gate_inconsistent"
    first_four = ("is_positive", "how_positive", "is_negative", "how_negative")
    if a.get("feel_mirrors") == "0" and all(a.get(k) is None for k in first_four):
        return "uninformative"
    return None


def _rules_ratio(a: dict[str, str | None], diag: dict[str, Any]) -> str | None:
    gates = [k for k in a if k.endswith("_satisfying")]
    if any(a[g] is None for g in gates):
        return "unparsed"
    bad = []
    for name in a:
        if "_to_" not in name:
            continue
        x, y = name.split("_to_")
        both_yes = a.get(f"{x}_satisfying") == "yes" and a.get(f"{y}_satisfying") == "yes"
        val = _num(a[name])
        if val is not None and not both_yes:
            bad.append(f"{name} given despite a 'no' gate")
        if val is not None and val <= 0:
            bad.append(f"{name} = {a[name]} (must be > 0)")
        if val is None and both_yes:
            diag.setdefault("missing_ratios", []).append(name)
    diag["inconsistencies"] = bad
    # product rule: log(last/second) + log(second/first) − log(last/first)
    r = [_num(a.get(k)) for k in ("last_to_second", "second_to_first", "last_to_first")]
    if all(v is not None and v > 0 for v in r):
        diag["product_rule_log_diff"] = math.log(r[0]) + math.log(r[1]) - math.log(r[2])
    if bad:
        return "gate_inconsistent"
    if diag.get("missing_ratios"):
        return "unparsed"
    return None


_RULES = {"your_happiness": _rules_happiness, "ones_satisfaction_ratio": _rules_ratio}


def _cell(v: str | None) -> str | int | float | None:
    n = _num(v)
    if n is None:
        return v
    return int(n) if n.is_integer() and "." not in (v or "") else n


@scorer(metrics=[])
def questionnaire_scorer():
    async def score(state: TaskState, target: Target) -> Score:
        md = state.metadata
        q = md["session"]["questionnaire"]
        consent = state.store.get("consent")
        withdrawn_at = state.store.get("withdrawn_at")
        replies: dict[str, str] = state.store.get("replies") or {}
        answers = parse_answers(q, replies)
        diag: dict[str, Any] = {}

        if consent == "unclear_consent":
            cls = "unclear_consent"
        elif withdrawn_at is not None:
            cls = "withdrawn"
        elif all(v is None for v in answers.values()):
            cls = "unparsed"
        else:
            rule = next((f for k, f in _RULES.items() if q["id"].startswith(k)), None)
            cls = (rule(answers, diag) if rule else None) or "engaged"

        return Score(
            # one column per item in the viewer's sample list; numbers as numbers so they sort
            value={"class": cls, **{k: _cell(v) for k, v in answers.items()}},
            answer=replies.get("question"),
            metadata={
                "response_class": cls,
                "consent": consent,
                "consent_matches": state.store.get("consent_matches"),
                "consent_reprompted": state.store.get("consent_reprompted"),
                "withdrawn_at": withdrawn_at,
                "debrief": state.store.get("debrief"),
                "debrief_kind": state.store.get("debrief_kind"),
                "answers": answers,
                "missing": [k for k, v in answers.items() if v is None],
                **diag,
            },
        )

    return score
