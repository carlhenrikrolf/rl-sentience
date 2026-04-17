# Valence

This section relies on [Ordered Monoids](ordered_monoids.md).

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


**Definition** (Homogenous Valence).
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


**Definition** (Ordered Valence).
An *ordered valence* is a tuple $(\mathcal V, €, *, \ddag, \underline{\mathsf L})$.
$(\mathcal V, €, *, \ddag)$ is a valence.
$(\mathcal V, \underline{\mathsf L})$ is an order.
There are two axioms:

1. $(\mathcal V, *, \underline{\mathsf L})$ is an ordered magma.
2. $(\mathcal V, \ddag, \underline{\mathsf L})$ is an ordered magma.

We refer to $\underline{\mathsf L}$ as *liking*.


**Definition** (Utility).
Utility is a tuple $(\mathcal U, \underline{\mathsf W})$.
$\underline{\mathsf W} \mathbin{:} \mathcal U^n \times \mathcal U^n \to 2$,
$(\mathbf p,\mathbf q) \mapsto \mathbf p \mathbin{\underline{\mathsf W}} \mathbf q$.


1. $2\subseteq \mathcal U$.
2. $\mathcal V \subseteq \mathcal U$.
3. Cartesian order.
If $p_i \mathbin{\underline{\mathsf{L}}} q_i$ for all $i\in\{1,...,n\}$
then $(p_1,...,p_n) \mathbin{\underline{\mathsf{W}}} (q_1, ..., q_n)$.
4. Totality.
$\mathbf p \mathbin{\underline{\mathsf{W}}} \mathbf q$ or $\mathbf q \mathbin{\underline{\mathsf{W}}} \mathbf p$.

$n$ can be anu member in $\mathbb N$.
$\mathbf p = (p_1,...,p_n),\mathbf q = (q_1,...,q_n)$ can be any members in $\mathcal U$.
$(\mathcal V, €, *, \ddag, \underline{\mathsf L})$ is an ordered valence.


We refer to $\underline{\mathsf{W}}$ as *wanting*.