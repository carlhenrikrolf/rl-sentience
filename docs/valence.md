# Valence

Here, we use sentient experiences as a subset of conscious experiences.
In addition to being conscious,
1. all sentient experiences feel positive, negative, or neutral, and.
2. some sentient experiences feel better than other.

## Preliminaries

To formalize the first property, we need a monoid where the identity element is used for the neutral point.

**Definition** (Monoid).
A *monoid* is tuple $(\mathcal V, €, *)$.
$€\in \mathcal V$
and $* \mathbin{:} \mathcal V \times \mathcal V \to \mathcal V$, $(p,q) \mapsto p * q$.
There are two axioms:

1. Associativity.
$(p * q) * r= p * (q * r)$.
2. Identity.
$€ * p = p * € = p$.

A *commutative monoid* is a monoid with one additional axiom:

3. Commutativity.
$p*q = q*p$.

$p,q,r$ can be any member of $\mathcal V$.

Note that a consequence of these axioms is that the identity element $€$ is unique.

To formalize the second property, we need a partial order.

**Definition** (Partial order).
A *partial order* is tuple $(\mathcal V,\preceq)$.
$\preceq \mathbin{:} \mathcal V \times \mathcal V \to \{0,1\}$, $(p,q) \mapsto p \preceq q$.
There are three axioms:

1. Reflexivity.
$p\preceq p$.
2. Transitivity.
If $p\preceq q$ and $q\preceq r$ then $p\preceq r$.
3. Antisymmetry.
If $p\preceq q$ and $q\preceq p$ then $p=q$.

A *semiorder* is a partial order with two additional axioms:

4. Interval order.
If $p\preceq q$ and $r\preceq s$
then $p\preceq s$ or $r\preceq q$.
5. Semiorder.
If $p\preceq q \preceq r$
then $s\preceq r$ or $p\preceq s$.

$p,q,r,s$ can be any member of $\mathcal V$.

Note that this does not mean all experiences are comparable.

## Model

**Definition** (Valence).
*Valence* is a tuple
$(\mathcal V, €, *, \ddag)$.
$(\mathcal V, €, *)$ is a monoid.
$\ddag \mathbin{:} \mathcal V \times \mathcal V \to \mathcal V$, $(p,q) \mapsto p \mathbin{\ddag} q$.
There are three axioms:

1. Right-identity.
$p\mathbin{\ddag}€ = p$.
2. $(€ \mathbin{\ddag} p) \mathbin{\ddag} q = (€ \mathbin{\ddag} p) * (€ \mathbin{\ddag} q)$.
3. $(p * q) \mathbin\ddag r = p * (q \mathbin\ddag r)$.

$p,q$ can be any member of $\mathcal V$.

A valence is commutative (over $*$)
if and only if $(p\mathbin{\ddag}q ) \mathbin{\ddag} r = (p\mathbin{\ddag}r)\mathbin{\ddag}q$.

[Proof.]()

$(\mathcal V, €, \circledast)$ is a *group*
if

- Inverse. $p\circledast q \coloneqq p*q$
and $r * (€ \mathbin{\ddag} r) = €$, or
- Anticommutativity. $p \circledast q \coloneqq € \mathbin{\ddag} ((€\mathbin{\ddag} p) \mathbin{\ddag} q)$
and $€ \mathbin{\ddag} (p \mathbin{\ddag} q) = q \mathbin{\ddag} p$.

$p,q,r$ can be any member in $\mathcal V$.
Inverse holds by definition.
Anticommutativity and right-identity suffice for a group.

[Proof.]()

*Introspection*.
Find a pair of stimuli $(X,Y)$ such that $X$ causes you pleasure and $Y$ causes you discomfort.
Is there any level of **$X$ which is equally pleasurable as $Y$ is uncomfortable**?
If so, you may model your hedonic experiences with groups.
Otherwise, if that comparison does not make sense, you may model your hedonic experiences with valences instead.


**Definition** (Partially ordered valence).
*Partially ordered valence* is a tuple $(\mathcal V, €, *, \ddag, \preceq)$.
$(\mathcal V, €, *, \ddag)$ is a valence.
$(\mathcal V, \preceq)$ is a partial order.
There are four axioms:

1. Left-invariance over $*$.
If $p\preceq q$
and $€ \preceq r$
then $r * p\preceq r * q$.
2. Right-invariance over $*$.
If $p\preceq q$
and $€ \preceq r$
then $p * r\preceq q * r$.
3. Left-invariance over $\ddag$.
If $p \preceq q$
and $r \preceq €$
then $r \mathbin{\ddag} p \preceq r \mathbin{\ddag} q$.
4. Right-invariance over $\ddag$.
If $p \preceq q$
and $r \preceq €$
then $p \mathbin{\ddag} r \preceq q \mathbin{\ddag} r$.

$p,q,r$ can be any member of $\mathcal V$.

==TODO==
Check these axioms.

==TODO==
*Introspection*.
Feeling the unit ...

**Definition** (Homogenous valence).
A *homogenous valence over $\mathcal K$* is a tuple
$(\mathcal V, €, *, \ddag, \|\|)$
equipped with an field
$(\mathcal K, 0,+,1, \cdot)$.
$(\mathcal V, €, *, \ddag)$ is a valence.
$\|\|: \mathcal V \to \mathcal K$, $p \mapsto \|p\|$.
There are two axioms:

1. Homogeneity.
$n \cdot \|p\| = \|\overbrace{p * \cdots * p}^{n\ \mathrm{times}}\|$.
2. Positive definiteness.
$\|p\|=0$
if and only if $p=€$.

$p$ can be any member of $\mathcal V$
and $n$ can be any member of $\mathcal K$.

$n \cdot \|€ \mathbin{\ddag} p\| = \| (( € \mathbin{\ddag} \overbrace{p) \mathbin{\ddag} \cdots ) \mathbin{\ddag} p}^{n\ \mathrm{times}}\|$
is a consequence of homogeneity and axiom 2 from the definition of valence.

[Proof.]()

==TODO==
*Experiments* (Stevens).
Power laws ...

- Cross-modality.
$\|\| \mathbin{:} \mathcal K \to \mathcal K$.

A *homogenous partially ordered valence* is a tuple
$(\mathcal V, €, *, \ddag, \preceq, \|\|)$
where $(\mathcal V, €, *, \ddag, \preceq)$ is a partially ordered valence,
and $(\mathcal V, €, *, \ddag, \|\|)$ is a homogenous valence.

==TODO==
*Experiments* (Weber–Fechner).
Just noticeable differences (JNDs) ...

- Fechner.
If $p \preceq q$
and not $p=q$
then $\|q \mathbin{\ddag} p\|\geq1$.