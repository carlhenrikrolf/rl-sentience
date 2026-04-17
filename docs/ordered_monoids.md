# Ordered Monoids

Here, we use sentient experiences as a subset of conscious experiences.
In addition to being conscious,
1. all sentient experiences feel positive, negative, or neutral, and.
2. some sentient experiences feel better than other.


To formalize the first property, we need a monoid where the identity element is used for the neutral point.

**Definition** (Magma).
A *magma* is a tuple $(\mathcal V, *)$.
$* \mathbin{:} \mathcal V \times \mathcal V \to \mathcal V$, $(p,q) \mapsto p * q$.
A *cancellative magma* is a magma with two additional axioms:

1. Left-cancellation.
If $r*p=r*q$ then $p=q$.
2. Right-cancellation.
If $p*r=q*r$ then $p=q$.

$p,q,r$ can be any members of $\mathcal V$.

**Definition** (Monoid).
A *monoid* is tuple $(\mathcal V, €, *)$.
$€\in \mathcal V$
and $(\mathcal V, *)$ is a magma.
There are two axioms:

1. Associativity.
$(p * q) * r= p * (q * r)$.
2. Identity.
$€ * p = p * € = p$.

A *commutative monoid* is a monoid with one additional axiom:

3. Commutativity.
$p*q = q*p$.

$p,q,r$ can be any members of $\mathcal V$.

Note that a consequence of these axioms is that the identity element $€$ is unique.

To formalize the second property, we need a partial order.

**Definition** (Order).
A *partial order* (abbreviated with the prefix *po-*) is tuple $(\mathcal V,\preceq)$.
$\preceq \mathbin{:} \mathcal V \times \mathcal V \to 2$, $(p,q) \mapsto p \preceq q$.
There are three axioms:

1. Reflexivity.
$p\preceq p$.
2. Transitivity.
If $p\preceq q$ and $q\preceq r$ then $p\preceq r$.
3. Antisymmetry.
If $p\preceq q$ and $q\preceq p$ then $p=q$.

A *total order* (abbreviated with the prefix *to-*) is a partial order with one additional axiom:

4. Totality. $p \preceq q$ or $q \preceq p $.

$p,q,r$ can be any members of $\mathcal V$.

**Definition** (Strict Order).

A *partial order* is tuple $(\mathcal V,\prec)$.
$\prec \mathbin{:} \mathcal V \times \mathcal V \to 2$, $(p,q) \mapsto p \prec q$.
A strict partial order can be defined from a partial order $(\mathcal V, \preceq)$:

1. $p\prec q$ whenever $p\preceq q$ and not $p=q$.

<!-- 1. Irreflexivity.
Not $p\preceq q$.
2. Transitivity.
If $p\prec q$ and $q\prec r$
then $p\prec r$.
1. Asymmetry.
If $p \prec q$
then not $q \prec p$. -->

A *semiorder* is a strict partial order with two additional axioms:

2. Interval order.
If $p\prec q$ and $r\prec s$
then $p\prec s$ or $r\prec q$.
3. Semiorder.
If $p\prec q \prec r$
then $s\prec r$ or $p\prec s$.

$p,q,r,s$ can be any members of $\mathcal V$.


The two properties can be combined.


**Definition** (Ordered Magma).
An *ordered magma* is a tuple $(\mathcal V, *, \preceq)$.
$(\mathcal V, *)$ is a magma.
$(\mathcal V, \preceq)$ is an order.
There are two axioms:

1. Left-invariance.
If $p\preceq q$
then $r * p\preceq r * q$.
2. Right-invariance.
If $p\preceq q$
then $p * r\preceq q * r$.

$p,q,r$ can be any members of $\mathcal V$.

An *ordered monoid* is a tuple $(\mathcal V, €, *)$,
where $(\mathcal V, *)$ is an ordered magma.
