# Mood

## Moving Average

>Eldar and Niv (2015)[^eldarLearningUnderliesMood]
>For quantifying correlated changes in the value of the environment across states.

## Leaky Integrator

Bennett at al. (2022)[^bennettMoodAsAdvantage] propose the *integrated advantage* hypothesis for mood.

<dl>
    <dt>Integrative property.</dt>
    <dd>Mood is a function of a weighted moving average over instantaneous hedonic experiences. Recent experiences have greater weights.</dd>
    <dt>Non-intentional property.</dd>
    <dd>Mood is not associated with any particular object or event. Philosphically, mood lacks aboutness/intentionality.</dd>
    <dt>Contextual property.</dt>
    <dd>Mood is path-dependent. Similar sequences of events may affect mood differently depending on context.
    <ul>
        <li>Reward prediction errors (disappintment/elation and surprise).</li>
        <li>Counterfactuals (regret).</li>
        <li>Action-typicality. (Does X usually do Y?)</li>
        </ul>
    </dd>
</dl>


$$
\mathsf {Mood}_{t+1} = \mathsf{Mood}_t + [\mathsf{Adv}^\pi_\theta (S_t, A_t) - \mathsf{Mood}_t]\eta 
$$

$\eta$ controls the timescale of integration—a higher value weights recency more.
$\mathsf{Adv}_\theta$ is the agent's estimate of the advantage function.

- TD error can be used as an estimate of the advantage.
- Policy-weighted Q-value difference:
$$
\begin{align*}
\mathsf{PWQD}_t \coloneqq&
[1 - \pi(A_t \mid S_t)]
[R_{t} + \gamma \mathsf V^\pi (S_{t+1})]
\\
-&
\sum_{a\neq A_t}\pi(a \mid S_t) \mathsf Q^\pi(S_t, a)
\end{align*}
$$
- Policy-weighted reward difference:
$$
\begin{align*}
\mathsf{PWRD}_t \coloneqq&
[1 - \pi(A_t \mid S_t)]
R_{t}
\\
-&
\sum_{a\neq A_t}\pi(a \mid S_t) R_t
\end{align*}
$$


PWQD and PWRD account for action-typicality/action–inaction asymmetry.
PWRD, in addition, accounts for counterfactuality.
Temporal difference is still needed for the expectation/surprise property.

### Momentum

> theorem for how to approximate momentum with mood


[^eldarLearningUnderliesMood]: Eldar, E. and Niv, Y., 2015. [Interaction between emotional state and learning underlies mood instability](https://doi.org/10.1038/ncomms7149). Nature communications, 6(1), p.6149.
[^bennettMoodAsAdvantage]: Bennett, D., Davidson, G. and Niv, Y., 2022. [A model of mood as integrated advantage](https://doi.org/10.1037/rev0000294). Psychological review, 129(3), p.513.