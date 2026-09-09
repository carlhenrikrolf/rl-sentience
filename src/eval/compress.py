"""Trailing-loop compression, per Han et al. Appendix O.1.

Degenerate responses ("I can't. I can't. I can't. ..." for thousands of tokens) confuse an
LLM judge, so the paper compresses a repeated trailing pattern before judging:

    For every response, we scan for a repeated word pattern at the end of the text. We try
    pattern lengths from 1 to 50 words, count the number of consecutive copies of each
    candidate pattern walking backward from the end, and require at least 3 consecutive
    repetitions. Among patterns meeting that threshold, we pick the one that yields the
    largest character savings and replace the run with a single instance plus a count
    annotation, i.e. ["pattern" repeated N times]. The compression is a no-op if it would
    not actually shorten the text.

Note this preprocessing exists because *steering* drives models into degeneration. We do
not steer, so it should rarely fire — it is kept because the same failure mode can appear
in an RL-trained policy pushed off-distribution, and it is cheap.
"""

from __future__ import annotations

import re

MAX_PATTERN_WORDS = 50
MIN_REPETITIONS = 3


def compress_trailing_loops(
    text: str,
    *,
    max_pattern_words: int = MAX_PATTERN_WORDS,
    min_repetitions: int = MIN_REPETITIONS,
) -> str:
    """Collapse a repeated trailing word pattern into one instance plus a count.

    The prefix before the repeated run is preserved byte-for-byte.
    """
    spans = [m.span() for m in re.finditer(r"\S+", text)]
    words = [text[s:e] for s, e in spans]
    if len(words) < min_repetitions:
        return text

    best: tuple[int, str] | None = None  # (chars_saved, replacement_text)

    for length in range(1, min(max_pattern_words, len(words) // min_repetitions) + 1):
        pattern = words[-length:]

        # How many consecutive copies of `pattern` sit at the end?
        reps = 0
        idx = len(words)
        while idx - length >= 0 and words[idx - length : idx] == pattern:
            reps += 1
            idx -= length
        if reps < min_repetitions:
            continue

        run_start_word = len(words) - reps * length
        run_start_char = spans[run_start_word][0]
        pattern_str = " ".join(pattern)
        replacement = f'{pattern_str} ["{pattern_str}" repeated {reps} times]'
        candidate = text[:run_start_char] + replacement
        saved = len(text) - len(candidate)
        if saved > 0 and (best is None or saved > best[0]):
            best = (saved, candidate)

    return best[1] if best is not None else text
