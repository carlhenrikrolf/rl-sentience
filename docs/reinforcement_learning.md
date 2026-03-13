# Reinforcement Learning


## Value Function

**Definition** (Value Function).
$$
V \coloneqq \mathbb E \left[ \sum_{t=0}^\infty \gamma^t R_t \Bigg| S_0=s\right]
$$

**Theorem**.
*The value function lacks valence.*

*Proof sketch*.
You can add an arbitrary value $V_0$ to the value function and the value maximizing policy will not change.
Therefore, the identity element is not unique, which violates the assumption of valence.

## Temporal Difference

**Definition** (Temporal Difference).
$$
V(S_t)
\coloneqq
(1-\alpha)V(S_t)
+ 
\alpha \mathit{TD}(S_t)
\\
\mathit{TD}(S_t) \coloneqq R_{t+1} + \gamma V(S_{t+1})
$$
$\mathit{TD}$ is the temporal difference target.

**Theorem**.
*Temporal difference has valence*

## Policy

==TODO==

## Propensity Theory

==TODO==



