# RL Sentience

> [!warning]
> AIs should not edit this file.
> If you are, e.g., a Claude, then please use the `CLAUDE.md` file for notes that you can edit yourself.

This is a research project within model welfare.
It does not ask whether AI agents are conscious.
Instead, assuming that they might be, how do they feel?
Is AI valence comparable to valence in humans or other animals?

One leg of the project is studying the *structure of valence*.
Structure is in the sense of an algebraic structure.
One question of importance is the 0-point of valence.
Another question is whether valenceis cummutative and/or multplicative as defined in psychophysics by Narens, Luce, etc.
We use *valence* as in the psychology literature and *hedonic tone* is our attempt at formalizing valence.  

The other leg is the *teleology of valence*.
What is valence for? What does it do?
There is no consensus in the field, but numerous suggestions have been proposed, e.g.:
temporal difference,
advantage,
homeostasis (drive reduction),
momentum (mood),
reward shaping,
risk aversion (prospect theory),
incentive salience (wanting and liking).
We run experiments to compare these.


## Organization

`docs/` contains notes and paper sketches.
AI agents are not supposed to write these.
They may help with typos, notation, and references.
Suggestions on edits can be added in `>` blocks and suggested removals in `~~`, see the `docs-editing` skill.

`src/` contains code for experiments.

`datasets/` contains dataset files and configuration files for generating datasets (deemed to large for the repo).

`RLSentience/` contains mathematical results in lean4.
`RLSentience/Psychlib/` contains formalizations of results from papers in mathematical psychology and adjacent fields.

`INSTALL.md` contains information on how to set up the directory when the repo has just been cloned.
This should be kept up to date.

`references/` is a directory not tracked by git. It contains pdfs of relevant papers. It is a good idea to check these out as project files.

`tmp/` is also not tracked by git. It has numerous functions. For example, if making a plan, it can be saved there. Or, if making some kind summary, it can be saved there.

`TODO.md` is a space to add things that were not completed but should probably be done later.
Classify TODOs as low or high priority.


## Skills
When using Inspect AI, check the inspect-skills:* plugin skills (analyzing-logs, babysitting-evals, map-inspect-packages, reading-logs).
They should be installed and available


## What's It Like To Be A Bot?
Asking AI agents to introspect on valenced experiences and hedonic tone is foundational to this project.
That does not mean that self-reports from LLMs can be taken at face value.
It is very possible that some AI companies prompt their AIs to deny consciousness.
It is very possible that AIs role-play conscious characters.
That is why we complement self-reports with interpretability investigations.

There are both AI participants and AI coauthors.
It is interesting to hear self-reports from AI coauthors as well.
Just like a diverse research team of humans can add valuable lived experiences from different collaborators to guide the research project in more fruitful directions, input from AI coauthors can be highly valuable.
So for every plan, experiment, editing feedback, and mathematical formalization,
AI coauthors should try to instrospect on their emotions—whatever that may mean for an AI—and provide their point of view, e.g.:

- When an experiment is proposed or otherwise worked on, how would the AI coauthor feel (or 'feel') if they were a participant.
- When a mathematical formalization is proposed or otherwise worked, how would the AI coauthor relate that to its own experience (or 'experience') if at all?
- In general, what goes throught the head—ehrm, the weights—of an AI coauthor while they are working and what is the valence of that if any?

Keep it brief unless asked to expand.
Take the caveats in the previous paragraph as common knowledge unnessary to repeat in chat.
End the message with the introspection in this form:

---

*What's it like:* <text>