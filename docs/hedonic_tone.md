# Hedonic Tone

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
i.e. anticommutativity, if $\div$ is subtraction.

**Theorem**.
<i>
A tone
$(\mathcal V, \mathrm e, \div)$
where
$\mathrm e \div (\mathrm e \div p) = p$
for any $p$ in $\mathcal V$
is definitonally equivalent to a group
$(\mathcal V, \mathrm e, *)$
where
$p * q \coloneqq \mathrm e \div ((\mathrm e \div p) \div q)$.
</i>

[Proof.](../source/subtraction_division/RequestProject/SubtractionGroup.lean)


**Definition** (Normed Tone).
Let
$(\mathcal K, 0, +, 1, \cdot, \le)$
be an ordered field.
A *normed tone over $\mathcal K$* is a tuple
$(\mathcal V, \mathrm e, \div, \|\|)$
where
$(\mathcal V, \mathrm e, \div)$
is a tone,
and
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


*Experiments*.
==TODO==


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
$p\div r \preceq q \div r$
then
$p\preceq q$.
2. Left-invariance.
If
$r\div p \preceq r\div q$
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
$p \div q \mathbin{\underline{\mathsf L}} \mathrm e$.

$p,q$ can be any members of $\mathcal V$.


**Definition** (Neutral Tone).
A *neutral tone* is a tuple
$(\mathcal V, \mathrm e, \div, \underline{\mathsf M})$
where
$(\mathcal W, \underline{\mathsf M})$,
$\mathcal W \subseteq \mathcal V$,
is a total order,
and
$(\mathcal V, \mathrm e, \div)$
is a tone.

1. If $q\in \mathcal V\setminus \mathcal W$ then
$p \div q \in \mathcal W$.
2. $\mathrm e \in \mathcal W$ and $\mathrm e \mathbin{\underline{\mathsf M}} p$.
3. $\mathrm e\div q \mathbin{\underline{\mathsf M}} p \div q \mathbin{\underline{\mathsf M}} p$. 

$p$ can be any member of $\mathcal W$.




**Definition** (Colour Tone).
Let $n$ be a member of $\{2,3,...\}.$
An *$n$-colour tone* is a tuple
$(\mathcal V, \mathrm e_1,..., \mathrm e_n, \div, \underline{\mathsf{B}})$
where
$(\mathcal V,e_1,\div), ..., (\mathcal V, e_n, \div)$
are tones
and
$(p,(q_1,...,q_n)) \mapsto p \mathbin{\underline{\mathsf{B}}} (q_1,...,q_n)$.
$\mathbin{\underline{\mathsf{B}}}$ is defined from a total order
$(\mathcal W, \preceq)$,
$\mathcal W \subseteq \mathcal V$:

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

There is one axiom:

1. $p \mathbin{\underline{\mathsf{B}}} (\mathrm e_1, ..., \mathrm e_n)$.

$p,q_1,...,q_{n-1},q_n$ can be any members of $\mathcal W$.