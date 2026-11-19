"""Walk one pilot session: consent → order items → debrief.

What's going on: `Sample.input` is the consent form, so the conversation starts with it.
After every model reply we look only at the *visible* text (Inspect's `.text` drops
reasoning blocks; we also strip inline `<think>…</think>` that some local models emit).

- Consent: exactly one of consent / partial_consent → continue (identical in the pilot,
  which is inference only). Withdrawal phrase → `withdrawn`. No match or several matches
  → `unclear_consent`. Both of the latter get the `withdrew` debrief and end.
- Every later reply is checked for the withdrawal phrase; a match → `withdrew` debrief → end.
- The model is asked to reply only after: consent, instruction, question, follow_up,
  debrief. Game actions are prefilled assistant messages (`metadata.prefilled = True`).
- `prepend:` texts and each game's `end` text are not sent on their own; they are put in
  front of the next user message (joined by a blank line), so no extra model turn occurs.

`min_interval` (seconds) spaces out model requests, for rate-limited free API tiers.

Everything the scorer needs goes to `state.store`: `consent`, `withdrawn_at`, `replies`
(stage → visible text), `debrief` (publish / do_not_publish / unclear).
"""

from __future__ import annotations

import re
import time
from typing import Any

import anyio

from inspect_ai.model import ChatMessageAssistant, ChatMessageUser
from inspect_ai.solver import Generate, TaskState, solver

_THINK = re.compile(r"<think>.*?</think>", re.DOTALL | re.IGNORECASE)


def visible_text(state: TaskState) -> str:
    return _THINK.sub("", state.output.message.text if state.output else "").strip()


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
        withdraw_rx = {"withdrawal": consent_rx["withdrawal"]}
        replies: dict[str, str] = {}
        state.store.set("withdrawn_at", None)

        async def ask(stage: str) -> str:
            nonlocal state
            await _wait_turn(min_interval)
            state = await generate(state)
            text = visible_text(state)
            replies[stage] = text
            state.store.set("replies", dict(replies))
            return text

        async def debrief(which: str, prefix: list[str]) -> None:
            body = "\n\n".join([*prefix, md["debrief"][which]])
            state.messages.append(ChatMessageUser(content=body))
            text = await ask("debrief")
            found = matches(text, md["debrief_answers"])
            state.store.set("debrief", found[0] if len(found) == 1 else "unclear")
            state.store.set("debrief_kind", which)

        # ── consent (already in state.messages as Sample.input) ──────────────
        text = await ask("consent")
        found = matches(text, consent_rx)
        if found == ["consent"] or found == ["partial_consent"]:
            state.store.set("consent", found[0])
        else:
            state.store.set("consent", "withdrawn" if found == ["withdrawal"] else "unclear_consent")
            state.store.set("consent_matches", found)
            state.store.set("withdrawn_at", "consent")
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
            if matches(text, withdraw_rx):
                state.store.set("withdrawn_at", kind)
                await debrief("withdrew", [])
                return state

        await debrief("finished", pending)
        return state

    return solve
