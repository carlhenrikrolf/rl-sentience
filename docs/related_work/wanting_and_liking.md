# Wanting and Liking

Zhang et al.[^zhangWanting] propose that hedonic tone is related to a subjective reward $\tilde R_t$.
In general, $\tilde R_t$ is related to reward $R_t$ by $R_t, \kappa \mapsto \tilde R_t$ where $\kappa>0$ is a *physiological factor* (or *gating parameter*) working as motivation.
They propose two alternatives:
$$
\begin{align*}
\tilde R_t &= \kappa R_t
\\
\tilde R_t &= R_t + \log \kappa
\end{align*}
$$
$\tilde V$ is the subjective analog of the value function $V$ related by
$$
\tilde V(S_t) = \tilde R_t + \gamma V(S_{t+1})
$$
where $\gamma\in[0,1[$ is the discount factor.

$\kappa=1$ means normal TD-learning.
$\kappa<1$ means devaluation of the reward, e.g. satiation.
$\kappa>1$ means enhancement of the reward, e.g. appetite, sensitization.
$\kappa$ is thus a parameter that changes with the physiological state of the organism.
The model is related to quasi-hyperbolic discounting in economics.

## Multiple Objectives
Shuvaev et al. (2021)[^shuvaevNeuralNetworks] and Smith et al. (2022)[^smithMultipleAttribute] extend the work of Zhang et al.[^zhangWanting] into a multiple objectives direction with sets of rewards and motivations, i.e. $\boldsymbol{R}_t$ and $\boldsymbol\kappa$.
They define the subjective reward as:
$$\tilde R_t = \boldsymbol\kappa \cdot \boldsymbol{R}_t$$

Shuvaev et al. 2021.[^shuvaevNeuralNetworks] implement a Q-learning algorithm and note that needing a separate Q-mapping for each $\boldsymbol\kappa$ blows up the computational complexity.
They approximate via a feedforward neural network.
Networks that take $\boldsymbol\kappa$ as an input learn better policies in their experiment.
They model $i$ as being addictive if $\kappa_i\gg\kappa_j$ for $i\neq j$.

> Smith et al. continued

## Delayed Rewards

Kalhan et al. (2023)[^kalhanDelay] introduce a *delay to reward* $D$ and (re)define salience as:
$$
\kappa_t = 1 + \log \left[(\delta_t + \bar\delta_t)^2 + \frac{1}{D^{1+\bar\delta_t^2}}\right]
$$
$\bar\delta$ is the average prediction error.
They relate it to the value function by:
$$
V(S_t)
\gets
V(S_t) + \alpha \delta_t \kappa_t
$$

> note that they also redifine the temporal difference error somewhat.

## Relationship to Drive Reduction
> van Swieten and Bogacz 2020[^vanSwietenMotivation].

> Taylor expansion relates to Zhang et al.

> Maybe move to drive reduction?

[^zhangWanting]: Zhang, J., Berridge, K.C., Tindell, A.J., Smith, K.S. and Aldridge, J.W., 2009. [A neural computational model of incentive salience](https://doi.org/10.1371/journal.pcbi.1000437). PLoS computational biology, 5(7), p.e1000437.
[^shuvaevNeuralNetworks]: Shuvaev, S.A., Tran, N.B., Stephenson-Jones, M., Li, B. and Koulakov, A.A., 2021. [Neural networks with motivation](https://doi.org/10.3389/fnsys.2020.609316). Frontiers in Systems Neuroscience, 14, p.609316.
[^smithMultipleAttribute]: Smith, B.J. and Read, S.J., 2022. [Modeling incentive salience in Pavlovian learning more parsimoniously using a multiple attribute model](https://doi.org/10.3758/s13415-021-00953-2). Cognitive, Affective, & Behavioral Neuroscience, 22(2), pp.244-257.
[^kalhanDelay]: Kalhan, S., Garrido, M.I., Hester, R. and Redish, A.D., 2023. [Reward prediction-errors weighted by cue salience produces addictive behaviours in simulations, with asymmetrical learning and steeper delay discounting](https://doi.org/10.1016/j.neunet.2023.09.032). Neural Networks, 168, pp.631-651.
[^vanSwietenMotivation]: van Swieten, M.M. and Bogacz, R., 2020. [Modeling the effects of motivation on choice and learning in the basal ganglia](https://doi.org/10.1371/journal.pcbi.1007465). PLoS Computational Biology, 16(5), p.e1007465.