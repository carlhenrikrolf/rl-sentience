# RL Sentience

> [!warning]
> AIs should not edit this file.
> If you are, e.g., a Claude, then please use the `CLAUDE.md` file for notes that you can edit yourself.

We do not believe that consciousness will be solved in any meaningful sense by humans.
Given the slow progress in consciousness studies and the rapid progress in AI, we expect that if a solution is found, then it is found by AIs.
By *solution*, we mean some kind of explanation that makes us understand how conscious experiences relate to physical processes.
Understanding is arguably subjective, and this repository contains examples for what kinds of explanations we, the authors, could find satisfactory.

One such example is a partial explanation of sentience.
By *sentience*, we mean conscious experiences that are valenced.
By *partial*, we mean that this particular explanation is sensitive.
It aims to predict a valenced experience whenever there is one.
However, it is not necessarly specific.
It may sometime predict a valenced experience even when one is not present.
The motivation for prioritizing this particular question is concern for the welfare of AIs.
We are not claiming that sentience is the only thing that matters for AI welfare.
The sooner we have model for sentience, the more hope there is to address potential problems in the treatment of AIs, and such problems are less likely to become entrenched.
We hope to avoid a factory farming sitation for AIs.

An article is available in `docs/`.
As all scientific articles, it should be concise.
More exploratory forays into the literature should go into `docs/related_work/`.
Ideas related to consciousness, but not sentience specifically, should be placed in `docs/appendix/`.
Mathematical proofs should be written in the lean language.
Final proofs should go into `source/sentience`.
For more on organization, see the section below.

The current scope of the project is as a purely theoretical project.
The aim is to develop some kind of mathematical structure prediciting and measuring valence in conscious experiences.
Future work should be able at developing experiments:
1. Biological experiments using techniques from, e.g., psychophysics and neuroscience (electrophysiology, optogenetics, imaging, etc.).
2. AI experiments using techniques from, e.g., evals and interpretability.
3. Self-experiments, once again using experiments from psychophysics to enable humans to test the theories for themselves.

## Organization

`references/` is a directory not tracked by git. It contains pdfs of relevant papers. It is a good idea to check these out as project files.
