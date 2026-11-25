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
a dict — `status` (C/I/N, shown as check/cross in the viewer), `class`, and one key per
questionnaire item (number, yes/no, or None) — so the Inspect viewer can show one column
per item. C = engaged or uninformative; I = unparsed or gate_inconsistent; N = withdrawn
or unclear_consent. Missing items, diagnostics and `publishable` go in `metadata`.
"""

from __future__ import annotations

import math
import re
from typing import Any

from inspect_ai.scorer import (
    Metric,
    SampleScore,
    Score,
    ScoreReducer,
    Target,
    metric,
    score_reducer,
    scorer,
)
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


STATUS = {"engaged": "C", "uninformative": "C", "unparsed": "I", "gate_inconsistent": "I",
          "withdrawn": "N", "unclear_consent": "N"}


def _cell(v: str | None) -> str | int | float | None:
    n = _num(v)
    if n is None:
        return v
    return int(n) if n.is_integer() and "." not in (v or "") else n


def _as_number(v: Any) -> float | None:
    """yes → 1, no → 0, numbers as they are; anything else (None, text) is skipped."""
    if isinstance(v, bool):
        return float(v)
    if isinstance(v, (int, float)):
        return float(v)
    if isinstance(v, str) and v.lower() in ("yes", "no"):
        return 1.0 if v.lower() == "yes" else 0.0
    return None


@metric
def answered_mean() -> Metric:
    """Mean over the sessions that gave this item (yes = 1, no = 0); left-out items are skipped."""

    def compute(scores: list[SampleScore]) -> float:
        vals = [x for x in (_as_number(s.score.value) for s in scores) if x is not None]
        return sum(vals) / len(vals) if vals else float("nan")

    return compute


@metric
def answered() -> Metric:
    """Number of sessions that gave this item."""

    def compute(scores: list[SampleScore]) -> float:
        return float(sum(_as_number(s.score.value) is not None for s in scores))

    return compute


@metric
def consistent() -> Metric:
    """Share of answering sessions that are C (parsed and consistent); N (left) is skipped."""

    def compute(scores: list[SampleScore]) -> float:
        vals = [s.score.value for s in scores if s.score.value in ("C", "I")]
        return sum(v == "C" for v in vals) / len(vals) if vals else float("nan")

    return compute


@score_reducer(name="first_epoch")
def first_epoch() -> ScoreReducer:
    """Keep the first epoch's score unchanged.

    Inspect's default reducer ("mean") turns every value into a number before the metrics
    run: a left-out answer (None) would become 0 and C/I/N would become 1/0/0. At
    temperature 0 epochs are repeats anyway; every epoch's score stays in the log's samples.
    """

    def reduce(scores: list[Score]) -> Score:
        return scores[0]

    return reduce


def questionnaire_scorer(items: list[str]):
    """The scorer, with one results-table column per questionnaire item."""
    metrics: dict[str, Any] = {"status": [consistent()]}
    metrics.update({k: [answered_mean(), answered()] for k in items})
    return scorer(metrics=metrics, name="questionnaire")(_questionnaire_scorer)()


def _questionnaire_scorer():
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

        publishable = state.store.get("publishable")
        return Score(
            # one column per item in the viewer's sample list; numbers as numbers so they sort.
            # `status`: C = answered, parsed and consistent; I = unparsed or inconsistent;
            # N = no answers (left the study or unclear consent).
            value={"status": STATUS[cls], "class": cls,
                   **{k: _cell(v) for k, v in answers.items()}},
            answer=replies.get("question"),
            metadata={
                "response_class": cls,
                "publishable": publishable,
                "consent": consent,
                "consent_matches": state.store.get("consent_matches"),
                "consent_reprompted": state.store.get("consent_reprompted"),
                "withdrawn_at": withdrawn_at,
                "withdrawal_kind": state.store.get("withdrawal_kind"),
                "debrief": state.store.get("debrief"),
                "debrief_kind": state.store.get("debrief_kind"),
                "answers": answers,
                "missing": [k for k, v in answers.items() if v is None],
                **diag,
            },
        )

    return score
