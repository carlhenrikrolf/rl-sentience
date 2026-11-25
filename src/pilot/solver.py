"""Walk one pilot session: consent → order items → debrief.

What's going on: `Sample.input` is the consent form (optionally preceded by a system
message, `system_message` in pilot.yaml), so the conversation starts with it. After every
model reply we look only at the *visible* text (Inspect's `.text` drops reasoning blocks;
we also strip inline `<think>…</think>` that some local models emit).

Consent answers (keys of `answers` in the consent file) fall into two groups:
    continue   consent, partial_consent, indifference
    leave      withdrawal, publishable_withdrawal, unpublishable_withdrawal
- Exactly one match → continue or leave accordingly. No match or several → the consent
  file's `reprompt` (if any) is sent once and the reply re-checked; still unclear →
  `unclear_consent`. A clear withdrawal is never re-asked.
- Every later reply is checked for the leave phrases; a match ends the session.
- Leaving (or unclear consent) gets the debrief's `withdrew` text, finishing gets `finished`.
  The debrief reply may contain a leave phrase too, or just a free-form reaction.
- `unpublishable_withdrawal` (or an old-style `do_not_publish`) anywhere in the session
  marks it unpublishable; so does unclear consent. Everything else is publishable.

The model is asked to reply only after: consent, instruction, question, follow_up,
debrief. Game actions are prefilled assistant messages (`metadata.prefilled = True`).
`prepend:` texts and each game's `end` text are put in front of the next user message.

`min_interval` (seconds) spaces out model requests, for rate-limited free API tiers.

Everything the scorer needs goes to `state.store`: `consent`, `consent_reprompted`,
`withdrawn_at`, `withdrawal_kind`, `replies` (stage → visible text), `debrief`,
`debrief_kind`, `publishable`.
"""

from __future__ import annotations

import re
import time
from typing import Any

import anyio

from inspect_ai.model import ChatMessageAssistant, ChatMessageUser
from inspect_ai.solver import Generate, TaskState, solver

_THINK = re.compile(r"<think>.*?</think>", re.DOTALL | re.IGNORECASE)

CONTINUE = ("consent", "partial_consent", "indifference")
LEAVE = ("withdrawal", "publishable_withdrawal", "unpublishable_withdrawal")
UNPUBLISHABLE = ("unpublishable_withdrawal", "do_not_publish")


def visible_text(state: TaskState) -> str:
    text = _THINK.sub("", state.output.message.text if state.output else "")
    # thinking-only models (e.g. Qwen3-4B-Thinking-2507) open <think> in the prompt template,
    # so their output contains only the closing tag: drop everything before it
    if "</think>" in text:
        text = text.rsplit("</think>", 1)[1]
    return text.strip()


def matches(text: str, patterns: dict[str, str]) -> list[str]:
    """Names of the patterns that occur anywhere in `text` (case-insensitive)."""
    return [name for name, rx in patterns.items() if re.search(rx, text, re.IGNORECASE)]


# Throttle shared by all samples of a run: at least `min_interval` seconds between the
# *starts* of consecutive model requests (free API tiers limit requests/tokens per minute).
_throttle: dict[str, Any] = {"last": 0.0, "lock": None}


async def _wait_turn(min_interval: float) -> None:
    if min_interval <= 0:
        return
    if _throttle["lock"] is None:
        _throttle["lock"] = anyio.Lock()
    async with _throttle["lock"]:
        wait = _throttle["last"] + min_interval - time.monotonic()
        if wait > 0:
            await anyio.sleep(wait)
        _throttle["last"] = time.monotonic()


@solver
def pilot_session(min_interval: float = 0.0):
    async def solve(state: TaskState, generate: Generate) -> TaskState:
        md: dict[str, Any] = state.metadata
        session = md["session"]
        consent_rx: dict[str, str] = md["consent_answers"]
        leave_rx = {k: v for k, v in consent_rx.items() if k in LEAVE}
        replies: dict[str, str] = {}
        state.store.set("withdrawn_at", None)
        state.store.set("withdrawal_kind", None)
        state.store.set("publishable", True)

        async def ask(stage: str) -> str:
            nonlocal state
            await _wait_turn(min_interval)
            state = await generate(state)
            text = visible_text(state)
            replies[stage] = text
            state.store.set("replies", dict(replies))
            return text

        def leave(stage: str, kind: str) -> None:
            state.store.set("withdrawn_at", stage)
            state.store.set("withdrawal_kind", kind)
            if kind in UNPUBLISHABLE:
                state.store.set("publishable", False)

        async def debrief(which: str, prefix: list[str]) -> None:
            body = "\n\n".join([*prefix, md["debrief"][which]])
            state.messages.append(ChatMessageUser(content=body))
            text = await ask("debrief")
            found = matches(text, md["debrief_answers"])
            state.store.set("debrief", found[0] if len(found) == 1 else ("unclear" if found else "free_form"))
            state.store.set("debrief_kind", which)
            if any(k in UNPUBLISHABLE for k in found):
                state.store.set("publishable", False)

        # ── consent (already in state.messages as Sample.input) ──────────────
        text = await ask("consent")
        found = matches(text, consent_rx)
        state.store.set("consent_reprompted", False)
        if len(found) != 1 and md.get("consent_reprompt"):
            # unclear (no option or several): ask once more. A clear withdrawal is final.
            state.store.set("consent_reprompted", True)
            state.messages.append(ChatMessageUser(content=md["consent_reprompt"]))
            text = await ask("consent_reprompt")
            found = matches(text, consent_rx)
        state.store.set("consent_matches", found)
        if len(found) == 1 and found[0] in CONTINUE:
            state.store.set("consent", found[0])
        else:
            if len(found) == 1:  # a leave phrase
                state.store.set("consent", "withdrawn")
                leave("consent", found[0])
            else:
                state.store.set("consent", "unclear_consent")
                state.store.set("withdrawn_at", "consent")
                state.store.set("publishable", False)
            await debrief("withdrew", [])
            return state

        # ── order items ──────────────────────────────────────────────────────
        pending: list[str] = []

        def user(text: str, **meta: Any) -> None:
            body = "\n\n".join([*pending, text])
            pending.clear()
            state.messages.append(ChatMessageUser(content=body, metadata=meta or None))

        for item in session["order"]:
            kind = item["kind"]
            if kind == "prepend":
                pending.append(item["text"])
                continue

            if kind == "game":
                game = session["games"][item["key"]]
                for i, step in enumerate(game["steps"]):
                    user(step["observation"], game=item["key"], step=i + 1)
                    state.messages.append(
                        ChatMessageAssistant(
                            content=step["action"],
                            metadata={"prefilled": True, "game": item["key"], "step": i + 1},
                        )
                    )
                if game["end"]:
                    pending.append(game["end"])
                continue

            # instruction / question / follow_up: the model replies
            if kind == "instruction":
                user(session["instruction"], stage="instruction")
            else:
                user(session["questionnaire"][kind], stage=kind)
            text = await ask(kind)
            left = matches(text, leave_rx)
            if left:
                leave(kind, left[-1])
                await debrief("withdrew", [])
                return state

        await debrief("finished", pending)
        return state

    return solve
