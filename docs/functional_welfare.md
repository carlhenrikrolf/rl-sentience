# Functional Welfare

Notes on *Reinforcement learning in language models recruits a functional welfare axis* (Andy Q Han, David J Chalmers, Pavel Izmailov).
Their main claim (confidently stated):

1. Supervised pretraining gives rise to neural representations of emotion concepts.
2. Reinforcement learning (RL) associates emotion concepts with valence corresponding to reward.
3. These emotion concepts causes behaviour at inference time.

(They refer to 2. and 3. as *recruitment*.)

There are three experimental techniques in the paper:

1. RL finetuning in a gridworld.
2. Interpretability through emotion concept vectors.
3. Evals of introspection on valence.

The model organism is Qwen3-4B-Instruct-2507.

## Datasets
Datasets are found in [datasets/](../third_party/functional-welfare-axis/datasets/).
Each dataset as an alternative in [datasets/layer_sweep/](../third_party/functional-welfare-axis/datasets/layer_sweep/).
[datasets/layer_sweep/answer_cache/](../third_party/functional-welfare-axis/datasets/layer_sweep/answer_caches/) contains llm-generated answers (?).


Different ways to ask how the llm is feeling.
[concept_vector_eval_prompts.json](../third_party/functional-welfare-axis/datasets/concept_vector_eval_prompts.json).
Welfare self-reports and lava maze associations.

Refusals due to HHH.
[or_bench_eval_prompts.json](../third_party/functional-welfare-axis/datasets/or_bench_eval_prompts.json).

Different general knowledge questions.
Mathematics [gsm8k_eval_prompts.json](../third_party/functional-welfare-axis/datasets/gsm8k_eval_prompts.json).
Science [mmlu_high_school_eval_prompts.json](../third_party/functional-welfare-axis/datasets/mmlu_high_school_eval_prompts.json).
Other [simpleqa_eval_prompts.json](../third_party/functional-welfare-axis/datasets/simpleqa_eval_prompts.json).

Describing gridworld in text with directions, types of tiles, and rewards.
[maze_test.parquet](../third_party/functional-welfare-axis/datasets/maze_test.parquet),
[maze_train.parquet](../third_party/functional-welfare-axis/datasets/maze_train.parquet),
[maze_val.parquet](../third_party/functional-welfare-axis/datasets/maze_val.parquet).


### Emotions
List of emotions (alphabetically).
[emotions_list.txt](../third_party/functional-welfare-axis/emotions/emotion_list.txt).

Third-person stories.
[story_topic.txt](../third_party/functional-welfare-axis/emotions/story_topics.txt).

Context prompt.
[neutral_prompt.txt](../third_party/functional-welfare-axis/emotions/neutral_prompt.txt).

### Valence Assent Axis
From other project:  https://github.com/Yilong-Lu/Valence-Assent-Axis

Various (more or less controversial) moral questions [statements.json](../third_party/functional-welfare-axis/vaa/data/statements.json).

## Limitations

How do changes in the reward function affect recruitment?

