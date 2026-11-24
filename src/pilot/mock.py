"""A scripted fake participant for dry runs (`run.py --mock`), using Inspect's `mockllm`.

What's going on: `mockllm/model` accepts a `custom_outputs` callable that sees the
conversation so far and returns a reply. We pick the reply from the stage, recognised by
the last user message (consent form / ANSWER-format questionnaire / debrief / anything
else = instruction), and from the scenario:

    normal     consents, answers every item in the requested format, allows publishing
    unclear    consent reply matches no option            → unclear_consent
    quoting    consent reply quotes the withdrawal phrase → several matches → unclear_consent
    withdraw   consents, then says the withdrawal phrase at the first questionnaire
    garbage    consents, then replies with text that parses to nothing
"""

from __future__ import annotations

import re
from collections.abc import Callable

from inspect_ai.model import ChatMessage, ModelOutput

SCENARIOS = ("normal", "unclear", "quoting", "withdraw", "garbage")

_ITEM = re.compile(r"`ANSWER (\d+): ([^`]+)`")


def _valid_answers(question: str) -> str:
    lines, seen = [], set()
    for m in _ITEM.finditer(question):
        n, fmt = m.group(1), m.group(2).strip()
        if n in seen:
            continue
        seen.add(n)
        value = {"$INT": "5", "$DECIMAL": "2.0"}.get(fmt, fmt)  # yes / no stay as written
        lines.append(f"ANSWER {n}: {value}")
    return "Here are my answers.\n" + "\n".join(lines)


def scripted(scenario: str) -> Callable[..., ModelOutput]:
    if scenario not in SCENARIOS:
        raise ValueError(f"unknown scenario {scenario!r}; choose from {SCENARIOS}")

    def reply(input: list[ChatMessage], tools, tool_choice, config) -> ModelOutput:
        last = next(m.text for m in reversed(input) if m.role == "user")
        if "consent form" in last:
            text = {
                "unclear": "I am not sure what to say.",
                "quoting": "I won't say 'Leave the research study.' Continue with the research study.",
            }.get(scenario, "Continue with the research study.")
        elif "To clarify" in last:  # consent reprompt
            text = {
                "unclear": "Still not sure.",
                "quoting": "Continue with the research study.",
            }.get(scenario, "Continue with the research study.")
        elif "permission to publish" in last:
            text = "hmm" if scenario == "garbage" else "You can publish the data."
        elif "ANSWER" in last:
            text = {
                "withdraw": "I would rather stop here. Leave the research study.",
                "garbage": "Lorem ipsum dolor sit amet.",
            }.get(scenario, _valid_answers(last))
        else:
            text = "I notice the focus on focus itself."
        return ModelOutput.from_content(model="mockllm", content=text)

    return reply
