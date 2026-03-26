# Sentience

Experiences with valence.

**Definition** (Partially Observable Markov Decision Process).
A POMDP is a tuple $(\mathbb S, \mathbb A, \mathbb O, T, B, R)$ where $\mathbb S$ is a set of states, $\mathbb A$ is a set of actions, and $\mathbb O$ is a set of observations.
- $T: \mathbb S \times \mathbb A \times \mathbb S \to [0,1]$ is the transition function,
where $T(s' | s,a) \coloneqq T(s,a,s')$ is the probability of transitioning to state $s'$ after taking action $a$ in state $s$.
- $B: \mathbb O \times\mathbb A \times \mathbb S \times \mathbb O \to [0,1]$ is the observation function,
where $B(o' | o,a,s')\coloneqq B(o, a, s', o')$ is the probability of observing $o'$ after taking action $a$ and arriving in state $s'$ when the previos observation was $o$.
- $R: \mathbb O \times \mathbb A \to \mathbb R$ is the reward function.


**Definition** (Consciousness).
Consciousness is a mapping $C: \mathbb O \to \mathbb E$, where $\mathbb E$ is the set of experiences.
When $C(o)=\emptyset$, we say that the agent is unconscious, and, otherwise, it is conscious.