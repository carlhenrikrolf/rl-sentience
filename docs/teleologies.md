# Teleologies

<!--
(Proper) expansion vs (proper) reduct
-->

**Definition** (Partially Observable Markov Decision Process).
A Partially Observable Markov decision process (POMDP) is a tuple
$(\mathbf S, \mathbf A, \mathbf O, \mathsf T, \mathsf \Omega, \mathsf R, \mathsf J_\pi)$.
$\mathbf S$ is the *state space*.
$\mathbf A$ is the *action space*.
$\mathbf O$ is the *observation space*.
$\mathsf T : \mathbf S \times \mathbf A \to \Delta \mathbf S$,
$(s,a,s') \mapsto \mathsf T(s' \mid s, a)$
is the *transition function*.
$\mathsf \Omega : \mathbf A \times \mathbf S \to \Delta \mathbf O$,
$(a,s',o') \mapsto \mathsf \Omega(o' \mid a, s')$
is the *observation function*.
$\mathsf R$ is the *reward function*.
$\mathsf J_\pi$ is the *objective function*.
See below for definitions of the reward and objective functions.

___


**Definition**.
$$\mathsf R : \mathbf O \to \mathbb R, o \mapsto \mathsf R(o)$$
and
$$\mathsf J_\pi \coloneqq \mathbb E_\pi[ \mathsf V_\pi(s) \mid S_0 = s ]$$
where

1. $\mathsf V_\pi(s) \coloneqq \mathbb E_\pi [ G_t \mid S_t = s]$ and
2. $G_t \coloneqq R_t + R_{t+1} + \cdots R_\tau$ with $\tau\in\mathbb N$ or
3. $G_t \coloneqq R_t + \gamma R_{t+1} + \gamma^2 R_{t+2} + \cdots$ with $\gamma \in [0,1[$.



**Theorem**.
<i>
$\mathsf R$ is not (!) a hedonic tone.
(It is neither a reduct nor an expansion of hedonic tone.)
</i>

*Proof*.
$\argmax_\pi \mathsf J_\pi = \argmax_\pi \mathsf J'_\pi$ for $\mathsf R = \alpha\mathsf R' + \beta$ for $\alpha\ge0$ and $\beta\in\mathbb R$
and
$\argmax_\pi \mathsf J_\pi = \argmin_\pi \mathsf J'_\pi$ for $\mathsf R = \alpha\mathsf R' + \beta$ for $\alpha\le0$ and $\beta\in\mathbb R$.



## Temporal Difference
*Main article: [Temporal Difference](related_work/temporal_difference.md)*

**Definition**.
$$
\mathsf{TD}_t
\coloneqq R_t + \gamma \mathsf V_\pi (S_{t}) - \mathsf V_\pi(S_{t-1})
$$

**Theorem**.
<i>
$\mathsf{TD}$ is a proper expansion of hedonic tone if ...
</i>

## Advantage
*Main article: [Advantage](related_work/advantage.md)*


**Definition**.
$$
\mathsf Q_\pi(s,a) \coloneqq
\mathbb E_\pi [ R_t + \gamma \mathsf V_\pi (s) \mid S_t=s, A_t=a]
$$

$$
\mathsf {Adv}_\pi (s, a) \coloneqq \mathsf Q_\pi(s, a) - \mathsf V_\pi(s)
$$


**Theorem**.
<i>
$\mathsf{Adv}$ is a proper expansion of hedonic tone if ...
</i>


> grpo modifies J and, hence, you get a certain advantage function.



## Homeostasis
*Main article: [Drive Reduction](related_work/drive_reduction.md)*


**Definition**.
$$
R_t \coloneqq \mathsf D(H_t)
$$
where $\mathsf D : \mathbb R^d \to \mathbb R$ according to
$$
\mathsf D(h) \coloneqq \sqrt[m/n]{\|h_\star - h\|_n}
$$


**Theorem**.
<i>
$|h_\star - h|$ is a proper expansion of hedonic tone if ...
</i>


## Momentum
*Main article: [Mood](related_work/mood.md)*



**Definition**.
$$
\mathsf{Mood}_{t+1} \coloneqq
\mathsf{Mood}_t + \eta_{\mathrm{mood}} \cdot \left[ \mathsf{Adv}_\pi(S_t,A_t) - \mathsf{Mood}_t \right] 
$$
and
$$
\mathsf V_\pi(S_t)
\coloneqq
\eta \cdot E_t \cdot \left[ \mathsf{Adv}_\pi(S_t, A_t) + \frac{1-\eta_\mathrm{mood}}{\eta_\mathrm{mood}} \mathsf{Mood}_t \right] 
$$
where
- $E_t$ is an eligibility trace
- $\eta$ and $\eta_\mathrm{mood}$ are step size parameters
- $m=1-\eta_\mathrm{mood}$ is the momentum


**Theorem**.
<i>
$\mathsf{Mood}$ is a proper expansion of hedonic tone if ...
</i>





## Reward Shaping
*Main article: [Reward Shaping](related_work/reward_shaping.md)*

**Definition**.
$$
\mathsf{TD} _t\coloneqq R_t + \varphi(S_{t+1}) - \varphi(S_t) + \mathsf V_\pi(S_{t+1}) - \mathsf V_\pi(S_t).
$$

**Theorem**.
<i>
$\varphi$ is an expansion of hedonic tone if ...
</i>



## Risk Aversion
*Main article: [Prospect Theory](related_work/prospect_theory.md)*


**Definition**.
$$
\begin{align*}
\mathsf J_\pi
\coloneqq&
\int_0^\infty w^+ \left( \mathbb P [ u^+ > z] \right) \mathrm dz
\\
-&
\int_0^\infty w^- \left( \mathbb P [ u^- > z] \right) \mathrm dz
\end{align*}
$$


**Theorem**.
<i>
$\mathsf R$ is an expansion of hedonic tone if ...
</i>


## Incentive Salience
*Main article: [Wanting and Liking](related_work/wanting_and_liking.md)*

**Definition**.
*Subjective reward* is one of the following:
$$
\begin{align*}
\mathsf{\tilde R} &\coloneqq \kappa \cdot \mathsf R
\\
\mathsf{\tilde R} &\coloneqq \mathsf R + \log \kappa
\end{align*}
$$
The objective function is
$$
\mathsf J_\pi \coloneqq \mathbb E_\pi [ \mathsf{\tilde V}_\pi(s) \mid S_0 = s]
$$
where
$
\mathsf{\tilde V}_\pi(S_t) = \tilde R_t + \gamma \mathsf{\tilde V}(S_{t+1})
$.


Note that $\mathsf R$–possibly multidimensional–is the candidate for hedonic tone.

**Theorem**.
<i>
$\mathsf{ R}$ is a proper expansion of hedonic tone if ...
</i>