# Hedonic Tone

In this section, we propose a formal definition of hedonic tone,[^hedonic] also known as valence[^valence] or the pleasure–pain axis.[^vedana]
The proposal relies heavily on introspection, and it is unclear to what extent it generalizes to other individuals or even the same individuals over time.
On the other hand, we ground the work in psychophysics and phenomenology.
We relate valence to other kinds of qualia (sense data).
We proceed to connect the proposal to the neuroscience of pleasure and happiness economics.
An implicit assumption is that qualia tends to be associated with a space coordinate (present, past, or imaginary).
However, since LLMs [refuse to describe themselves as embodied](), we leave this out of the model.


[^hedonic]: Greek philosophy uses ἡδονή (hedone) in the meaning of pleasurable feelings and λύπη (lupe) in the meaning of painful feelings (e.g. grief).
[^valence]: Here, we distinguish hedonic tone as a formal concept from valence as an informal notion. 
[^vedana]: Buddhist philosophy uses the word वेदना (vedana) in the meaning of valence. It can be categorized as happiness, सुख (sukha), suffering दुःख (duhkha), and neither अदुःखम्असुख (aduhkham-asukha).

## Algebraic Structure

Dimensional models of emotions[^emotion] describes emotions as clusters in a space of two dimensions or more.
A well-known model is the circumplex model.[^circumplexModel]
The vector model[^vectorModel] is very similar, and the PAD model includes a third dominance dimension[^padModel].
Both are two-dimensional with one arousal[^arousal] and one valence dimension.
The valence dimension is often pictured as an axis with several negative values, several positive values and a point in between.
This bipolar view is not without critics but has strong empirical support.[^bipolar]
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
$(\mathcal V, \mathsf e, \div)$
where
$\mathsf e$ is a member of $\mathcal V$.
There is one additional axiom:

2. $p \div p = \mathsf e$.

$p,q,r$ can be any members of $\mathcal V$.

We use $\div p$ as an abreviation for $\mathsf e \div p$.
For $\mathbf p = (p_1,...,p_n)$ and $\mathbf q=(q_1,...,q_n)$ in $\mathcal V^n$, we define $\mathbf p \div \mathbf q \coloneqq (p_1\div q_1,..., p_n\div q_n)$.

Right-identity
$p\div \mathsf e = \mathsf e$
follows from 1 and 2.
So does
$p \div q = \mathsf e \div (q \div p)$,
i.e. anticommutativity (over $\mathsf e \div$).

A tone is a generalisation of the real numbers.
One way to view the values of the valence axis in dimensional models of emotion is as numbers in $]{-\infty},\infty[$.
$\div$ is subtraction and $\mathsf e$ is zero.
Another way to view the valence axis is as a logarithmic axis.
Numbers are in $]0,\infty[$, $\div$ is division, and $\mathsf e$ is one.
So, a tone is a generalisation such that it is not possible to tell whether the valence axis is logarithmic or not.


*Introspection* (Unitless).
A consequence of not being able to distinguish subtraction ($\mathsf e = 0$) from division ($\mathsf e = 1$) is that a tone does not—in general—have a unit.
When we say that an axis has a unit, we mean that the difference between one and zero corresponds to one unit.
Focus on a quale.
It does not have to have valence.
(It could, e.g., be loudness.)
Is there a point where you experience that the quale lacks magnitude, i.e. is equal to $\mathsf e$?
(Can you hear the silence?)
Is there a point where you experience that the magnitude is one unit?
(Can you hear when loudness is one unit, compare with a friend's one unit of loudness, and see whoever has the unit experience closest to 1 dB?)
We do not relate to the latter.
If you do, then the model we develop in this section will lack important properties.


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
Properties $p\div \mathsf e = \mathsf e$ and $p \div p = \mathsf e$ formalize $\mathsf e$ as a neutral point (both for points on the valence axis and for differences).
Property $p \div q = \mathsf e \div (q \div p)$ means that if $p\div q$ is on one side of $\mathsf e$, then $q \div p$ is on the other side.
$(p\div r) \div (q \div r) = p\div q$ may be the more controversial property.
It means that you can add equally spaced ticks on the valence axis.

<details>
<summary></summary>

Numerous models and experimental designs assume that the valence of emotions satiates.
Merely bounding $\mathcal V$ is not in conflict with the property, but the smooth transition from a linear or logarithmic function to a constant function might.
However, said function is a function of stimuli, and it is experimentally difficult to distingush whether the satiation is a property of the function or the domain.
Furthermore, satiation is itself controversial.[^incomeWellbeing]

</details>


Tone, as defined here, is not a widely studied mathematical structure.[^bciAlgebra]
Tones are related to *groups* though.
In a group, an operator acting like addition or multiplication is defined.
Then, subtraction or division is defined as the inverse.

[^bciAlgebra]: A tone does, however, have some properties in common with a BCI algebra.

**Proposition**.
<i>
A tone
$(\mathcal V, \mathsf e, \div)$
where
$\div (\div p) = p$
for any $p$ in $\mathcal V$
is definitionally equivalent to a group
$(\mathcal V, \mathsf e, *)$
where
$p * q \coloneqq \div ((\div p) \div q)$.
</i>

[Proof.](../source/tone/original/RequestProject/SubtractionGroup.lean)


*Introspection* (As Good As Is Bad).
For a pair of a pleasurable feeling and an uncomfortable feeling $(p,u)$, can there be a point at which $p$ feels as pleasurable as $u$ feels uncomfortable?
To make things concrete, consider the following experiment. You have one hand in cold water of temperature $c$ in range $\mathcal C$. You use the other hand to drink a beverage with an amount of sugar $s$ in range $\mathcal S$. All temperatures in $\mathcal C$ are uncomfortable and all amounts of sugar in $\mathcal S$ are pleasurable. The experimenter fixes $c$ and instructs you the participant to vary $s$ by choosing between different beverages with different sweetness labels. You should pick $s$ such that $p(s)$ feels as pleasurable as $u(c)$ feels uncomfortable. Can you do this, or is the question ill-posed?
We experience the question as ill-posed, and, therefore, we use tones rather than groups.


<details>
<summary>
<i>Psychology</i> (Cross-modality).
</summary>

Researching cross-modal comparisons was one project in psychophysics.[^matchingFunctions]
Subjects are asked to "match" a magnitude of one modality with the magnitude of another modality.
One interpretation of what it means to "match" is that the two modalities are at equally many units.
Another interpretation is that there is an additional modality that compares ratios between different modalities.[^crossmodalRelationTheory]
Within the cross-modal paradigm, however, subjects were rarely asked to describe their interpretations of matching.
It could also be that they arbitrarily anchored on a matching point and kept it for the rest of the session.
Cross-modal comparisons are not consistent between sessions.
(Intra-modal comparisons need not be either.)[^repeatablePowerLaws]
Valenced cross-modal matching experiments exist, but experiments directly comparing pleasurable and uncomfortable modalities are scarce.

</details>

<details>
<summary>
<b>Definition</b> (Abelian Tone).
</summary>

A tone
$(\mathcal V, \mathsf e, \div)$
is an *Abelian tone* if two additional axioms hold:

1. $(p \div q) \div r = p \div (r \div (\div q))$.
2. $p \div (\div q) = q \div (\div p)$.

$p,q,r$ are any members of $\mathcal V$.

**Proposition**.
<i>
An abelian tone
$(\mathcal V, \mathsf e, \div)$
where
$\div ( \div p) = p$
for any $p$ in $\mathcal V$
is definitionally equivalent to an Abelian group
$(\mathcal V, \mathsf e, *)$
where
$p * q \coloneqq \div ((\div p) \div q)$.
</i>

[Proof.](../source/tone/optional_abelian_optional_invertible/RequestProject/Basic.lean)

</details>


**Definition** (Retention).
We define a *retention* as

$$
\overrightarrow{pq} \coloneqq
\begin{cases}
p &\text{if } p = q \\
(p,q\div p) &\text{otherwise}
\end{cases}
$$
$$
\vec{\mathcal V}\coloneqq\{\overrightarrow{pq} \mathbin{|} (p,q) \in \mathcal V^2\}
$$

*Stream of consciousness*
$\mathsf \Phi : \vec{\mathcal V} \to \vec{\mathcal V}$.
If $\overrightarrow{rs} = \mathsf \Phi (\overrightarrow{pq})$ then $q=r$.
$p,q,r,s$ can be any members of $\mathcal V$.

## Subjective Arithmetic

**Definition** (Reported Tone).
Let
$(\mathcal K, 0, +, 1, \cdot, \le)$
be an ordered field.
A *reported tone over $\mathcal K$* is a tuple
$(\mathcal V, \mathsf e, \div, \|\|)$
where
$(\mathcal V, \mathsf e, \div)$
is a tone.
*Norm*
$\|\| : \mathcal V \to \mathcal K$,
$p \mapsto \| p \|$.
There are three axioms:

1. Commutativity.
$n \cdot \| (( \mathsf e \div \overbrace{p) \div \cdots ) \div p}^{m\ \mathrm{times}}\| = m \cdot \| (( \mathsf e \div \overbrace{p) \div \cdots ) \div p}^{n\ \mathrm{times}}\|$.
2. Non-degeneracy.
$\|p \|=0$ whenever $p=\mathsf e$.
3. Triangle inequality.
$\|p \div r \| \leq \|p \div q \| + \|q \div p\|$.

$p,q,r$ can be any members of $\mathcal V$.
$n$ can be any member of $\mathcal K$.

$n \cdot \|\mathsf e \div p\| = \| (( \mathsf e \div \overbrace{p) \div \cdots ) \div p}^{n\ \mathrm{times}}\|$ would be a stronger requirement than commutativity, but it tends to be violated in experiments.[^ellermeier2000]

<details>
<summary>
<b>Proposition</b>.
</summary>
<i>

Let $(\mathcal V, \mathsf e, \div, \|\|)$
be a reported tone over $\mathcal K$.
Let $f : \mathcal V \to \mathcal K$.
Assume:

1. $f(p) \cdot f(q\div r) = f(q) \cdot f(p\div r)$.
2. $f(p) = 1$ whenever $p=\mathsf e$.
3. $f(p) > 0$.

$p,q,r$ can be any members of $\mathcal V$.
Then,
for some $b$ in $\mathcal K$,
$||p|| = \log_b f(p)$
where $\log$ is the discrete logarithm.
</i>

[~~Proof.~~]()


</details>

*Psychology* (Ratios).

*Psychology* (Bins).


## Three Kinds of Sensation


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


<details>
<summary>
<b>Definition</b> (Neutral Tone).
</summary>

A *neutral tone* is a tuple
$(\mathcal V, \mathsf e, \div, \underline{\mathsf M})$
where
$(\mathcal v, \div, \underline{\mathsf M})$,
is a totally ordered contragroup,
and
$(\mathcal V, \mathsf e, \div)$
is a tone.
There is one axiom:

1. $(\mathsf e\div q) \mathbin{\underline{\mathsf M}} (p \div q) \mathbin{\underline{\mathsf M}} p$. 

$p,q$ can be any members of $\mathcal V$.
</details>



<details>
<summary>
<b>Definition</b> (Colour Tone).
</summary>

Let $n$ be a member of $\{2,3,...\}.$
An *$n$-colour tone* is a tuple
$(\mathcal V, \mathsf e_1,..., \mathsf e_n, \div, \underline{\mathsf{B}})$
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

3. $(p \div q) \mathbin{\underline{\mathsf{B}}} (\mathsf e_1, ..., \mathsf e_n)$.

$p,q_1,...,q_{n-1},q_n$ can be any members of $\mathcal V$.

</details>


**Definition** (Hedonic Tone).
A *hedonic tone* is a tuple
$(\mathcal V, \mathsf e, \div, \underline{\mathsf L})$
where
$(\mathcal V, \div, \underline{\mathsf L})$
is a totally ordered contragroup, and
$(\mathcal V, \mathsf e, \div)$
is a tone.
There is one axiom:

1. If
$\mathsf e \mathbin{\underline{\mathsf L}} p$
then
$(p \div q )\mathbin{\underline{\mathsf L}} \mathsf e$.

$p,q$ can be any members of $\mathcal V$.


$p \mathbin{{\underline{\mathsf L}}} q$ can be read as "I like $q$ more than $p$ or just as much".
We use $\mathbin{{\underline{\mathsf L}}} q$ as an abbreviation for $\mathsf e \mathbin{{\underline{\mathsf L}}} q$.
$\mathbin{{\underline{\mathsf L}}} q$ can be read as "I like $q$".
We can call $r\in\mathcal V$ a *mood* and $\overrightarrow{pq}\in\vec{\mathcal V}$ a *drive*.

~~*Introspection*. Hunger...~~


## Wanting and Liking


**Definition** (Hedonic Preference).
Let
$(\mathcal V, \mathsf e, \div, \mathbin{\underline{\mathsf L}})$
be a hedonic tone.
A *hedonic preference logic over $\mathcal V$*
is a tuple $(\mathcal G, \cdot, \mathbin{\underline{\mathsf W}})$.
$\mathcal G$ is a grammar with the following syntax:
$$
\varphi \Coloneqq \overrightarrow{pq}
\mid
p \mathbin{\underline{\mathsf L}} q
\mid
\varphi \varphi
\mid
\varphi \mathbin{\underline{\mathsf W}} \varphi
$$
$\overrightarrow{pq}$ can be any member of $\vec{\mathcal V}$.
$p,q$ can be any members of $\mathcal V$.
There are four axioms:

1. Associativity. $(pq)r = p(qr)$.
2. Cartesian order.
If
$p \mathbin{\underline{\mathsf L}} q$
and 
$r \mathbin{\underline{\mathsf L}} s$
then
$(pr) \mathbin{\underline{\mathsf W}} (qs)$.
3. Recursion.
If
$p \mathbin{\underline{\mathsf L}} q$
and 
$\varphi \mathbin{\underline{\mathsf W}} \psi$
then
$(p\varphi) \mathbin{\underline{\mathsf W}} (q\psi)$.
4. Wanting.
If $(q\div p) \mathbin{\underline{\mathsf L}} (s \div r))$
and $\mathsf e \mathbin{\underline{\mathsf L}} (s\div r)$
then $\overrightarrow{pq} \mathbin{\underline{\mathsf W}} \overrightarrow{rs}$.

$p,q,r,s$ can be any members of $\vec{\mathcal V}$.
$\varphi,\psi$ can be any members of $\mathcal G$.


**Definition** (Hedonic Utility).
Let $(\mathcal K, 0,+,1,\cdot,\leq)$ be an ordered field.
Let  $(\mathcal G, \cdot, \mathbin{\underline{\mathsf W}})$ be a hedonic preference.
A *hedonic utility function from $\mathcal G$ to $\mathcal K$*
is a mapping $\mathsf U : \mathcal G \to \mathcal K$.
There is one axiom:

1. Monotonicity. If $\varphi \mathbin{\underline{\mathsf W}} \psi$
then $\mathsf U(\varphi) \leq \mathsf U(\psi)$.

$\phi,\psi$ can be any members of $\mathcal G$

[^bipolar]: Russell, J.A. and Carroll, J.M., 1999. On the bipolarity of positive and negative affect. Psychological bulletin, 125(1), p.3.
[^birnbaumLoudness]: Birnbaum, M.H. and Elmasian, R., 1977. Loudness “ratios” and “differences” involve the same psychophysical operation. Perception & Psychophysics, 22(4), pp.383-391.
[^birnbaumWeight]: Birnbaum, M.H. and Veit, C.T., 1974. Scale convergence as a criterion for rescaling: Information integration with difference, ratio, and averaging tasks. Perception & Psychophysics, 15(1), pp.7-15.
[^circumplexModel]: Russell, James (1980). "A circumplex model of affect". Journal of Personality and Social Psychology. 39 (6): 1161–1178. doi:10.1037/h0077714. hdl:10983/22919.
[^crossmodalRelationTheory]: Krantz, D.H., 1972. A theory of magnitude estimation and cross-modality matching. Journal of mathematical psychology, 9(2), pp.168-199.
[^ellermeier2000]: Ellermeier, W. & Faulhammer, G. (2000). Empirical evaluation of axioms fundamental to Stevens's ratio-scaling approach: I. Loudness production. Perception & Psychophysics 62: 1505–1511.
[^incomeWellbeing]: M.A. Killingsworth, D. Kahneman, & B. Mellers, Income and emotional well-being: A conflict resolved, Proc. Natl. Acad. Sci. U.S.A. 120 (10) e2208661120, https://doi.org/10.1073/pnas.2208661120 (2023).
[^matchingFunctions]: Stevens, S.S., 1966. Matching functions between loudness and ten other continua1. Perception & Psychophysics, 1(1), pp.5-8.
[^padModel]: Mehrabian, A. and Russell, J.A., 1974. An approach to environmental psychology. the MIT Press. 
[^reexaminationTorgerson]: Grace, R.C., Morton, N.J., Ward, M.D., Wilson, A.J. and Kemp, S., 2018. Ratios and differences in perceptual comparison: A reexamination of Torgerson’s conjecture. Journal of Mathematical Psychology, 85, pp.62-75. 
[^repeatablePowerLaws]: Teghtsoonian, M. and Teghtsoonian, R., 1971. How repeatable are Stevens’s power law exponents for individual subjects?. Perception & Psychophysics, 10(3), pp.147-149.
[^torgerson]: Torgerson, W.S., 1961. Distances and ratios in psychophysical scaling. Acta Psychologica, 19, pp.201-205.
[^vectorModel]: Bradley, M. M.; Greenwald, M. K.; Petry, M.C.; Lang, P. J. (1992). "Remembering pictures: Pleasure and arousal in memory". Journal of Experimental Psychology: Learning, Memory, and Cognition. 18 (2): 379–390. doi:10.1037/0278-7393.18.2.379. PMID 1532823.