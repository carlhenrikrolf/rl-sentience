# RL Sentience

An investigation on whether LLMs feel discomfort or pleasure.

## Abstract

<b>

Some companies developing LLMs already do regular *model welfare* assesments.
Some intend to do so in the near future.
One of the top priorities in model welfare is whether LLMs have emotions.
It may not be possible to test whether LLMs consciously feel emotions,
but other features such as the relationship between discomfort and pleasure seem more tractable.
There is already work on self-report evalutations,
bail-out behaviours,
and mechanistic interpretability of emotion concepts.
Many human feelings, e.g. pain, nervousness, taste, are associated are associated bodily locations.
(Contribution 1) We are attempting to disprove the hypothesis that LLMs relate feelings to spatial coordinates.
LLMs do, however, express feelings or at least feelings-in-quotes.
(Contribution 2) We are developing a formal model of *hedonic tone*—a model describing common features (e.g. discomfort against pleassure) between human feelings and LLM "feelings".
A potential correlate of self-reported feelings of discomfort and pleasure is the output of the critic in actor–critic reinforcement learning algorithms.
Our model appears to predict that most actor–critics are not correlates of self-reported feelings, but that actor–critics with feedforward connections from the critic could be.
(Contriution 3) We are working on experiments to identify whether LLM self-reports of feelings are more consistent with critic behaviour in architectures with feedforward connections than without.

</b>

## Table of Contents

1. Embodiment Evals
2. [Hedonic Tone](docs/hedonic_tone.md)
3. Feedforward Actor–Critics

## Related Work

1. Reinforcement Learning
2. [Ordered Groups](docs/ordered_groups.md)

## Appendix