# Hedonic Tone

In this section, we propose a formal definition of hedonic tone,[^hedonic] also known as valence[^valence] or the pleasure–pain axis.[^vedana]
The proposal relies heavily on introspection, and it is unclear to what extent it generalizes to other individuals or even the same individuals over time.
On the other hand, we ground the work in psychophysics and phenomenology.
We relate valence to other other kinds of qualia (sense data).
We proceed to connect the proposal to the neuroscience of pleasure and happiness economics.


[^hedonic]: Greek philosophy uses ἡδονή (hedone) in the meaning of pleasurable feelings and λύπη (lupe) in the meaning of painful feelings (e.g. grief).
[^valence]: Here, we distinguish hedonic tone as a formal concept from valence as an informal notion. 
[^vedana]: Buddhist philosophy uses the word वेदना (vedana) in the meaning of valence. It can be categorized as happiness, सुख (sukha), suffering दुःख (duhkha), and neither अदुःखम्असुख (aduhkham-asukha).

Dimensional models of emotions[^emotion] describes emotions as clusters in a space of two dimensions or more.
A well-known model is the circumplex model.[^circumplexModel]
The vector model[^vectorModel] is very similar.
Both are two-dimensional with one arousal[^arousal] and one valence dimension.
The valence dimension is often pictured as an axis with several negative values, several positive values and a point in between.
We formalize two properties from this picture.
First, we can talk about differences in hedonic tone.
Second, there is a point that separates pain from pleasure—a point of both minimal pleasure and minimal pain.
We refer to the formalization simply as *tone* to clarify that it is a more general concept than hedonic tone.
It also encompasses neutral sensations.
Later, we develop what makes a tone hedonic step by step 


[^emotion]: There are numerous definitions of emotion within psychology. Here, we simply mean it as some subset of feelings. Hunger and thirst are feelings but are rarely counted as emotions. By feelings, we mean any valenced sensation. By sensing, we mean the experiential counterpart to sensing (what the sense organs do) and perception (what the brain does).
[^arousal]: In psychology, arousal is a collection of physiological responses involving, e.g., increased heart rate and blood pressure. 

**Definition** (Tone).
A *contragroup* is a tuple
$(\mathcal V, \div)$
where
$\div : \mathcal V \times \mathcal V \to \mathcal V$,
$(p,q) \mapsto p \div q$.
There is one axiom:

1. $(p\div r) \div (q \div r) = p\div q$.

A *tone* is a tuple
$(\mathcal V, \mathrm e, \div)$
where
$\mathrm e$ is a member of $\mathcal V$.
There is one additional axiom:

2. $p \div p = \mathrm e$.

$p,q,r$ can be any members of $\mathcal V$.

Right-identity
$p\div \mathrm e = \mathrm e$
follows from 1 and 2.
So does
$p \div q = \mathrm e \div (q \div p)$,
i.e. anticommutativity (over $\mathrm e \div$).

A tone is a generalisation of the real numbers.
One way to view the values of the valence axis in dimensional models of emotion is as numbers in $]{-\infty},\infty[$.
$\div$ is subtraction and $\mathrm e$ is zero.
Another way to view the valence axis is as a logarithmic axis.
Numbers are in $]0,\infty[$, $\div$ is division, and $\mathrm e$ is one.
So, a tone is a generalisation such that it is not possible to tell whether the valence axis is logarithmic or not.

*Psychology* (Torgerson's Conjecture).
Torgerson's conjecture is the observation that subjects do not distinguish subtraction and division in psychophysical experiments:

>It appears that
>the subject simply interprets this single relation in whatever way the
>experimenter requires. When the experimenter tells him to equate differences or to rate on an equal interval scale, he interprets the relation as a
>distance. When he is told to assign numbers according to subjective ratios,
>he interprets the same relation as a ratio.[^torgerson]

Torgerson based this conclusion on experiments on colour perception.
Birnbaum et al. extended it to weight[^birnbaumWeight] and loudness[^birnbaumLoudness], and further experiments have followed.
Nonetheless, the conjecture is not universally accepted.[^reexaminationTorgerson]


Having established that $\div$ is a generalization of subtraction and division, we turn to evaluating how reasonable the properties of a tone are.
Properties $p\div \mathrm e = \mathrm e$ and $p \div p = \mathrm e$ formalize $\mathrm e$ as a neutral point (both for points on the valence axis and for differences).
Property $p \div q = \mathrm e \div (q \div p)$ means that if $p\div q$ is on one side of $\mathrm e$, then $q \div p$ is on the other side.
$(p\div r) \div (q \div r) = p\div q$ may be the more controversial property.
It means that you can add equally spaced ticks on the valence axis.

<details>
<summary></summary>

Numerous models and experimental designs assume that the valence of emotions satiates.
Merely bounding $\mathcal V$ is not in conflict with the property, but the smooth transition from a linear or logarithmic function to a constant function might.
However, said function is a function of stimuli, and it is experimentally difficult to distingush whether the satiation is a property of the function or the domain.
Furthermore, satiation is itself controversial.[^incomeWellbeing]

</details>

*Introspection* (Unitless).
Another consequence of not being able to distinguish subtraction ($\mathrm e = 0$) from division ($\mathrm e = 1$) is that a tone does not—in general—have a unit.
When we say that an axis has a unit, we mean that the difference between one and zero corresponds to one unit.
Focus on a quale.
It does not have to have valence.
(It could, e.g., be loudness.)
Is there a point where you experience that the quale lacks magnitude, i.e. is equal to $\mathrm e$?
(Can you hear the silence?)
Is there a point where you experience that the magnitude is one unit?
(Can you hear when loudness is one unit, compare with a friend's one unit of loudness, and see whoever has the unit experience closest to 1 dB?)
We do not relate to the latter.
If you do, then the model we develop in this section will lack important properties.

<details>
<summary>
<i>Psychology</i> (Cross-modality).
</summary>

Researching cross-modal comparisons was one project in psychophysics.[^matchingFunctions]
Subjects are asked to "match" a magnitude of one modality with the magnitude of another modality.
One interpretation of what it means to "match" is that the two modalities are at equally many units.
Within the cross-modal paradigm, however, subjects were rarely asked to describe their interpretations of matching.
It could also be that they arbitrarily decided a matching point and kept it for the rest of the session.
Cross-modal comparisons are not consistent between sessions.
(Intra-modal comparisons need not be either.)[^repeatablePowerLaws]

</details>

Tone, as defined here, is not a widely studied mathematical structure.
Tones are related to *groups* though.
In a group, an operator acting like addition or multiplication is defined.
Then, subtraction or division is defined as the inverse.

**Theorem**.
<i>
A tone
$(\mathcal V, \mathrm e, \div)$
where
$\mathrm e \div (\mathrm e \div p) = p$
for any $p$ in $\mathcal V$
is definitionally equivalent to a group
$(\mathcal V, \mathrm e, *)$
where
$p * q \coloneqq \mathrm e \div ((\mathrm e \div p) \div q)$.
</i>

[Proof.](../source/subtraction_division/RequestProject/SubtractionGroup.lean)


*Introspection* (As Good As Is Bad).
For a pair of a pleasurable feeling and an uncomfortable feeling $(p,u)$, can there be a point at which $p$ feels as pleasurable as $u$ feels uncomfortable?
To make things concrete, consider the following experiment. You have one hand in cold water of temperature $c$ in range $\mathcal C$. You use the other hand to drink a beverage with an amount of sugar $s$ in range $\mathcal S$. All temperatures in $\mathcal C$ are uncomfortable and all amounts of sugar in $\mathcal S$ are pleasurable. The experimenter fixes $c$ and instructs you the participant to vary $s$ by choosing between different beverages with different sweetness labels. You should pick $s$ such that $p(s)$ feels as pleasurable as $u(c)$ feels uncomfortable. Can you do this, or is the question ill-posed?
We experience the question as ill-posed, and, therefore, we use tones rather than groups.

**Definition** (Retention).
We define a *retention* as
$$
\overrightarrow{pq} \mathrel{:=}
\begin{cases}
p &\text{if } p = q \\
(p,q\div p) &\text{otherwise}
\end{cases}
$$
Further, we define
$\vec{\mathcal V}\coloneqq\{\overrightarrow{pq} \mathbin{|} (p,q) \in \mathcal V^2\}$.
*Stream of consciousness*
$\mathsf \Phi : \mathcal V \to \vec{\mathcal V}$,
$p \mapsto \mathsf \Phi p$.
If $\overrightarrow{rs} = \mathsf \Phi \overrightarrow{pq}$ then $q=r$.
$p,q,r,s$ can be any members of $\mathcal V$.

**Definition** (Normed Tone).
Let
$(\mathcal K, 0, +, 1, \cdot, \le)$
be an ordered field.
A *normed tone over $\mathcal K$* is a tuple
$(\mathcal V, \mathrm e, \div, \|\|)$
where
$(\mathcal V, \mathrm e, \div)$
is a tone.
*Norm*
$\|\| : \mathcal V \to \mathcal K$,
$p \mapsto \| p \|$.
There are three axioms:

1. Homogeneity.
$n \cdot \|\mathrm e \div p\| = \| (( \mathrm e \div \overbrace{p) \div \cdots ) \div p}^{n\ \mathrm{times}}\|$.
2. Non-degeneracy.
$\|p \|=0$ whenever $p=\mathrm e$.
3. Triangle inequality.
$\|p \div r \| \leq \|p \div q \| + \|q \div p\|$.

$p,q,r$ can be any members of $\mathcal V$.
$n$ can be any member of $\mathcal K$.


Note that *norm* here refers to an *asymmetric seminorm* rather than its conventional meaning.


*Psychology* (Ratios).

*Psychology* (Bins).


***


**Definition** (Ordered Contragroup).
An *ordered tone* is a tuple
$(\mathcal V, \div, \preceq)$
where
$(\mathcal V, \div)$
is a contragroup, and
$(\mathcal V, \preceq)$
is an order.
There are two axioms:

1. Right-invariance.
If
$(p\div r) \preceq (q \div r)$
then
$p\preceq q$.
2. Left-invariance.
If
$(r\div p) \preceq (r\div q)$
then
$p\preceq q$.

$p,q$ can be any members of $\mathcal V$.


**Definition** (Hedonic Tone).
A *hedonic tone* is a tuple
$(\mathcal V, \mathrm e, \div, \underline{\mathsf L})$
where
$(\mathcal V, \div, \underline{\mathsf L})$
is a totally ordered contragroup, and
$(\mathcal V, \mathrm e, \div)$
is a tone.
There is one axiom:

1. If
$\mathrm e \mathbin{\underline{\mathsf L}} p$
then
$(p \div q )\mathbin{\underline{\mathsf L}} \mathrm e$.

$p,q$ can be any members of $\mathcal V$.


$p \mathbin{{\underline{\mathsf L}}} q$ can be read as "I like $q$ more than $p$ or just as much" and $\mathrm e \mathbin{{\underline{\mathsf L}}} q$ as "I like $q$".
We can call $r\in\mathcal V$ a *mood* and $\overrightarrow{pq}\in\vec{\mathcal V}$ a *drive*.

~~*Introspection*. Hunger...~~

<details>
<summary>
<b>Definition</b> (Neutral Tone).
</summary>

A *neutral tone* is a tuple
$(\mathcal V, \mathrm e, \div, \underline{\mathsf M})$
where
$(\mathcal v, \div, \underline{\mathsf M})$,
is a totally ordered contragroup,
and
$(\mathcal V, \mathrm e, \div)$
is a tone.
There is one axiom:

1. $(\mathrm e\div q) \mathbin{\underline{\mathsf M}} (p \div q) \mathbin{\underline{\mathsf M}} p$. 

$p,q$ can be any members of $\mathcal V$.
</details>



<details>
<summary>
<b>Definition</b> (Colour Tone).
</summary>

Let $n$ be a member of $\{2,3,...\}.$
An *$n$-colour tone* is a tuple
$(\mathcal V, \mathrm e_1,..., \mathrm e_n, \div, \underline{\mathsf{B}})$
where
$(\mathcal V, e_1,\div), ..., (\mathcal V, e_n, \div)$
are tones.<!-- $(p,(q_1,...,q_n)) \mapsto p \mathbin{\underline{\mathsf{B}}} (q_1,...,q_n)$. -->
*Betweenness*
$\mathbin{\underline{\mathsf{B}}}$ is defined recursively:

1. If $n=2$ then
$p \mathbin{\underline{\mathsf{B}}} (q_1,q_2)$
whenever
$q_1 \preceq p \preceq q_2$
or
$q_2 \preceq p \preceq q_1$.
2. If $n\ge3$ then
$p \mathbin{\underline{\mathsf{B}}} (q_1,...,q_n)$
whenever
there is an $r$ in $\mathcal V$ such that
$r \mathbin{\underline{\mathsf{B}}} (q_1,...,q_{n-1})$
and
either
$r \preceq p \preceq q_n$
or
$q_n \preceq p \preceq r$.

$(\mathcal V^n, \div, \preceq)$ is a totally ordered contragroup.
There is one axiom:

3. $(p \div q) \mathbin{\underline{\mathsf{B}}} (\mathrm e_1, ..., \mathrm e_n)$.

$p,q_1,...,q_{n-1},q_n$ can be any members of $\mathcal V$.

</details>


***



**Definition** (Preference).
Let $(\mathcal V, \mathrm e, \div, \underline{\mathsf L})$ be a hedonic tone
and
$m,n$ be any members of $\{1,2,...\}$.
A *preference over $\mathcal V$* is a tuple
$(\mathcal U, \underline{\mathsf W})$.
*Wanting*
$\underline{\mathsf W} \mathbin{:} \mathcal U^m \times \mathcal U^n \to 2$,
$(\mathbf p,\mathbf q) \mapsto \mathbf p \mathbin{\underline{\mathsf W}} \mathbf q$.

1. $\mathcal U = 2 \cup \mathcal V \cup \mathcal V^2$.
2. Cartesian order.
If $n=m$ and $p_i \mathbin{\underline{\mathsf{L}}} q_i$ for all $i\in\{1,...,n\}$
then $\mathbf p \mathbin{\underline{\mathsf{W}}} \mathbf q$.

$\mathbf p = (p_1,...,p_m)$ can be any member of $\mathcal U^m$ and $\mathbf q = (q_1,...,q_n)$ can be any member of $\mathcal U^n$.



[^birnbaumLoudness]: Birnbaum, M.H. and Elmasian, R., 1977. Loudness “ratios” and “differences” involve the same psychophysical operation. Perception & Psychophysics, 22(4), pp.383-391.
[^birnbaumWeight]: Birnbaum, M.H. and Veit, C.T., 1974. Scale convergence as a criterion for rescaling: Information integration with difference, ratio, and averaging tasks. Perception & Psychophysics, 15(1), pp.7-15.
[^circumplexModel]: Russell, James (1980). "A circumplex model of affect". Journal of Personality and Social Psychology. 39 (6): 1161–1178. doi:10.1037/h0077714. hdl:10983/22919.
[^incomeWellbeing]: M.A. Killingsworth, D. Kahneman, & B. Mellers, Income and emotional well-being: A conflict resolved, Proc. Natl. Acad. Sci. U.S.A. 120 (10) e2208661120, https://doi.org/10.1073/pnas.2208661120 (2023).
[^matchingFunctions]: Stevens, S.S., 1966. Matching functions between loudness and ten other continua1. Perception & Psychophysics, 1(1), pp.5-8.
[^reexaminationTorgerson]: Grace, R.C., Morton, N.J., Ward, M.D., Wilson, A.J. and Kemp, S., 2018. Ratios and differences in perceptual comparison: A reexamination of Torgerson’s conjecture. Journal of Mathematical Psychology, 85, pp.62-75. 
[^repeatablePowerLaws]: Teghtsoonian, M. and Teghtsoonian, R., 1971. How repeatable are Stevens’s power law exponents for individual subjects?. Perception & Psychophysics, 10(3), pp.147-149.
[^torgerson]: Torgerson, W.S., 1961. Distances and ratios in psychophysical scaling. Acta Psychologica, 19, pp.201-205.
[^vectorModel]: Bradley, M. M.; Greenwald, M. K.; Petry, M.C.; Lang, P. J. (1992). "Remembering pictures: Pleasure and arousal in memory". Journal of Experimental Psychology: Learning, Memory, and Cognition. 18 (2): 379–390. doi:10.1037/0278-7393.18.2.379. PMID 1532823.