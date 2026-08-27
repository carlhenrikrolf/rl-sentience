# Drive Reduction

Drive reduction was a theory of motivation developed in the 1940s and championed by Clark Hull.
In classical drive reduction theory, a *drive* is a represetnation of a physiolofical or psychological need which motivates the agent to satisfy said need.
A challenge of classical drive reduction theory is that it struggles to account fo pleasure seeking behaviours.

Keramati and Gutkin[^homeostatic] have proposed a model that combines Hull's drive-reduction theory with reinforcement learning—homeostatic RL—thereby addressing some of the issues with the former.
For formalization, see [lean4](../../RLSentience/Psychlib/DriveReduction/ARISTOTLE_SUMMARY.md).

## Definition

**Definition** (Homeostatic Space).
A homeostatic space is a tuple $(\mathbf H^N, D)$
where the *drive* $D$ is defined by:

$$
D(\boldsymbol h_t) \coloneqq \sqrt[m]{\sum_{i=1}^N |h_i^\star - h_{it}|^n}
$$

$\boldsymbol h_t = (h_{1t}, ..., h_{Nt})$ and $\boldsymbol h^\star = (h^\star_{1}, ..., h^\star_{N})$ can be any members in $\mathbf H$.
$n\geq m \geq 1$.

Note the following properties:
- As $n$ becomes larger and largen than $m$, $\boldsymbol h^\star$ goes from a homostatic setpoint to a hom-e-ostatic ($N$-dimensional) range.
- For a probability distribution $P$ such that $D(\boldsymbol h_t) = - \ln P(\boldsymbol h_t)$, drive is a measure of *surprise*.

**Definition** (Homeostatic Reward)
Let $R_t$ be a reward function.
$R_t$ is homeostatic whenever:
$$
R_t = D(\boldsymbol h_t) - D(\boldsymbol h_{t+1})
$$

**Theorem**.
<i>
Use SDR as an abbreviation for the sum of discounted rewards and SDD for the sum of discounted deviations.
If the discount factor is strictly less than 1,
then the maximum SDR equals the minimum SDD.
</i>

Note the following further properties:

1. The larger $\boldsymbol h_{t+1} - \boldsymbol h_t$ is, the more appetitive the stimulus is.
2. The larger $|\boldsymbol h^\star - \boldsymbol h_t|$ is, the more rewarding the stimulus is, i.e., the hungrier the organism, the more rewarding the stimulus.
3. When the deprivation level for one need increases, the reward for other needs get inhibited, e.g. hunger inhibits sexual behaviour.[^dickinsonBalleine]
4. The organism is risk-averse as per a concave utility function.


## Relationship to Wanting and Liking


## Applied to LLMs

Assume $\boldsymbol h_t$ is a function of activations, e.g. each $h_{it}$ is a weighted sum of activations.
In that case we could train a probe to learn $m$, $n$, and—perhaps most interestingly—$N$.
We could inject different $h_{it}$ and determine what the basic drives of the LLM in question are.


[^homeostatic]: Keramati, M. and Gutkin, B., 2014. Homeostatic reinforcement learning for integrating reward collection and physiological stability. Elife, 3, p.e04811.
[^dickinsonBalleine]: Dickinson A, Balleine BW. 2002. The role of learning in motivation. In Gallistel CR, Editor. Volume 3 of Steven's
Handbook of experimental psychology: learning, motivation, and Emotion. 3rd edition. New York: Wiley.
p. 497–533.