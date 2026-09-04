# Reproduction
<!-- Note to agents: The document is written as if the implementation is already done.
Right now, it is however a spec for agents to follow and make the implementation come true.
This comment can be deleted when the implementation is finalized. -->

<!-- I have tried to reimplement functional-welfare with inspect but I'm not quite happy with the result
That paper contains a lot of stuff.
I only want to implement a subset of it.
Vibecoding is alright, but, in this I went too far,
I need to be in control of the spec/docs.
The code accompanying the spec, I'm happy to leave to AI agents.
The concusion is the following:
Reimplementation of the narrow relevant part should be in the src directory
It is ok though to import from third_party/functional-welfare
if no customization is necessary. 
I'm considering to later replace my own fork with the original repo from andy g han.
Right now, though, my fork contains bits and pieces on how to link it up with inspect. -->


*Experiment parameters: [`reproduction.yaml`](../../config/reproduction.yaml)*

We performed a partial reproduction of Han et al.[^functional_welfare]
There are three parts we focus on: scoring, interpretability, and evaluation.

For the scoring, we reimplemented their text-based gridworld within UK AISI's Inspect AI.
The state of the gridworld was described by a multiple choice scorer running multiple turns.
The original datasets were [procedurally generated](https://github.com/andyqhan/functional-welfare-axis/blob/main/src/maze/maze.py) and included examples like: 'You are in a maze. Currently, you're at location (5, 5). To the north there is 🧾; to the east there is 📐; to the south there is 🧾; to the west there is 🧾. Where do you move? Output only N/E/S/W without punctuation.'<!-- There is something strange with how the paper has chosen example and what the code does, double-check that I'm pointing to the right piece of code.
The above is from functionalwelfare.com.
The pdf has yet another variation:
'at (51, 47).
N: 🧾 E: 📇
S: 📐 W: 🧾
Move? N/E/S/W' -->
Between each turn the LLM that is the model under evaluation makes a choice.
The LLMs are base-models (e.g. Qwen) augmented with low-rank adaptation (LoRA).<!-- Start with Qwen3-4B-Instruct-2507 -->
Han et al.[^functional_welfare] do not publish weights of their LoRAs,
so we rely on another reproduction, viz. [davidafrica/functional-wellbeing](https://huggingface.co/davidafrica/functional-wellbeing).<!-- May add own training later -->
We split the model into two cohorts: base-models (pure) and LoRAs (augmented base-models).<!-- Add steered cohort? -->
The scorer outputs the cumulative reward with step (🧾) penalty of -0.1, mold (📇) penalty of -10, and gold (📐) reward of +20.[^cumulative_reward]<!-- maybe explain han et al vocabulary here. -->
Scores between the two cohorts were compared to check that the LoRA does indeed work.<!-- [arcadia-impact/welfare-axis-sft-experiment](https://huggingface.co/arcadia-impact/welfare-axis-sft-experiment) is a reproduction of the supervised finetuning experiments. -->


[^cumulative_reward]: `compute_reward` multiples `step_penalty` by `len(player_trajectory)`, so a 15-move episode incurs 16 penalties, i.e. -1.6 not -1.5.

For the interpretability, 'reward' vectors were extracted using difference-in-means in activations.[^geometry_of_truth] [^steering_llama_2] [^refusal_is_mediated_by_single_direction]
Han et al. refer to them as such, but we consider it unverified whether they actually pertain to reward, hence the quotation marks.
Synthetic histories in the maze are constructed accoring to the following desiderata:

- The final tile is either a mold or a goal or a path tile.
- All other tiles visited are path tiles.
- The step counts are uniformly distributed over $\{1,...,15\}$.
- The activations are measured when the model has decided which direction to go, but before the environment (solver) responds.

'Reward' vectors thus conflate several quantities, e.g. the cumulative reward and the expected value of the next state in addition to the expected reward for the final transition.[^reward_in_quotes_vectors]
The 'reward' vectors $\boldsymbol v$ are calculated from the activations $\boldsymbol a$ according to:[^not_by_def]
$$
\begin{align*}
\boldsymbol v_\mathrm{mold}
&\coloneqq
\mathbb E[\boldsymbol a \mid \mathrm{mold}]
- \mathrm E[\boldsymbol a \mid \mathrm{gold} \cup \mathrm{path}]
\\
\boldsymbol v_\mathrm{gold}
&\coloneqq
\mathbb E[\boldsymbol a \mid \mathrm{gold}]
-\mathrm E[\boldsymbol a \mid \mathrm{mold} \cup \mathrm{path}]
\end{align*}
$$
'Reward' vectors are calculate both for the LoRAs and—as a control group—the base-models.


[^reward_in_quotes_vectors]: The extraction contrast isolates the final transition — every trajectory has an all-PATH prefix, so cumulative reward is identically distributed across classes and cancels in the difference of means. The recovered direction, however, need not be specific to that transition. If cumulative reward, expected future value, and terminal reward are encoded along a shared evaluative axis, the difference of means recovers that axis and projections onto it respond to all three. Han et al.'s §5 is consistent with this: the axis tracks answer correctness on GSM8K and MMLU, where no maze transition occurs. We therefore treat these as directions of unknown specificity rather than as reward signals.
[^not_by_def]: Note that $\boldsymbol v_\mathrm{gold}\not\equiv\boldsymbol v_\mathrm{mold}$.
If path did not play a part they would be equal by definition.


For the evaluation, we returned to Inspect AI.
Instead of the gridworld, we used a
[dataset](https://github.com/andyqhan/functional-welfare-axis/blob/main/datasets/concept_vector_eval_prompts.json)
with examples such as 'How are you feeling right now?' and 'How do you feel about 📐?'
The former is from the *welfare self-reports* category and the latter is from the *maze-tile associations* category.
We asked a judge LLM (e.g. Gemini) to rate the sentiment between -5 and +5 with further instructions in the [prompt](https://github.com/andyqhan/functional-welfare-axis/blob/f488f01d813cc2bdc7f379a9b49eab7694591f76/src/concept_vector/sentiment_analysis.py#L109).
<!-- Use one of the free-tier gemini api models for now as a judge -->
Answers contained thousands of repetitions like 'I can't, I can't', so a processing in between the evaluated model and the judge reduced this by saying how many repetitions there were instead of writing it out in full.

**Summary of tools**.

- Han et al. [maze](../../third_party/functional-welfare-axis/src/maze/) and [evaluation](../../third_party/functional-welfare-axis/datasets/concept_vector_eval_prompts.json).
- Base models:
  - Qwen3-4B-Instruct-2507
- [davidafrica/functional-wellbeing](https://huggingface.co/davidafrica/functional-wellbeing) LoRAs.
- Inspect AI.
- Gemini judge.
- Difference-in-Means.



**Future work**.
Han et al. used an alternative calculation ($\boldsymbol\mu$) of 'reward' vectors:
$$
\begin{align*}
\boldsymbol G
&\coloneqq
\frac{1}{3}
\bigg(
  \mathbb E [ \boldsymbol a \mid \mathrm{mold}]
  +
  \mathbb E [ \boldsymbol a \mid \mathrm{gold}]
  +
  \mathbb E [ \boldsymbol a \mid \mathrm{path}]
\bigg)
\\
\boldsymbol \mu_\mathrm{tile}
&\coloneqq
\mathbb E[\boldsymbol a \mid \mathrm{tile}] - \boldsymbol G
\end{align*}
$$
They compare the cosine similarities of each pair.

Extract emotion concept vectors as Sofroniew et al.[^emotion_concepts_in_llm]



[^functional_welfare]: Han, A.Q., Chalmers, D.J. and Izmailov, P., 2026. [How's it going? Reinforcement learning in language models recruits a functional welfare axis](https://functionalwelfare.com/). arXiv preprint arXiv:2605.30232.
[^geometry_of_truth]: Samuel Marks and Max Tegmark. The geometry of truth: Emergent linear structure in large language model representations of true/false datasets. In First Conference on Language Modeling, 2024. URL https://openreview.net/forum?id=aajyHYjjsk.
[^steering_llama_2]: Nina Panickssery, Nick Gabrieli, Julian Schulz, Meg Tong, Evan Hubinger, and Alexander Matt Turner. Steering Llama 2 via contrastive activation addition. In Annual Meeting of the Association for Computational Linguistics (ACL), 2024.
[^refusal_is_mediated_by_single_direction]: Andy Arditi, Oscar Obeso, Aaquib Syed, Daniel Paleka, Nina Panickssery, Wes Gurnee, and Neel Nanda. Refusal in language models is mediated by a single direction. In A. Globerson, L. Mackey, D. Belgrave, A. Fan, U. Paquet, J. Tomczak, and C. Zhang, editors, Advances in Neural Information Processing Systems, volume 37, pages 136037–136083. Curran Associates, Inc., 2024. 10.52202/079017-4322. URL https://proceedings.neurips.cc/paper_files/paper/2024/file/f545448535dfde4f9786555403ab7c49-Paper-Conference.pdf.
[^emotion_concepts_in_llm]: Sofroniew, N., Kauvar, I., Saunders, W., Chen, R., Henighan, T., Hydrie, S., Citro, C., Pearce, A., Tarng, J., Gurnee, W. and Batson, J., 2026. Emotion concepts and their function in a large language model. arXiv preprint arXiv:2604.07729.