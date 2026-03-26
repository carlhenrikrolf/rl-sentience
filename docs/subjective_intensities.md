# Subjective Intensities

**Definition** (Monoid).
A monoid is tuple $(\mathbb A,*)$ with three axioms:
- *Associativity*.
$(a* b) * c=a* (b * c)$.
- *Identity*.
There is an $ e\in \mathbb V$ such that $ e * a = a *  e= a$.
$e$ is called the identity element (or *Einheit*).

$a,b,c$ can be any element in $\mathbb A$.

**Definition** (Order).
A partial order is tuple $(\mathbb A,\preceq)$ with three axioms:
- *Reflexivity*.
$a\preceq a$.
- *Transitivity*.
If $a\preceq b$ and $b\preceq c$ then $a\preceq c$.
- *Antisymmetry*.
If $a\preceq b$ and $b\preceq a$ then $a=b$.

A total order is a partial order with an additional axiom:
- *Totality*. $a\preceq b$ or $b\preceq a$.

$a,b,c$ can be any element in $\mathbb A$.

## Three Kinds



**Definition** (Unipolar Intensity).
A unipolar intensity is a tuple
$(\mathbb U, \mathbf 0, \preceq)$.
- $(\mathbb U, \preceq)$ is a total order.
- $\mathbf 0 \in \mathbb U$ where $\mathbf 0 \preceq \mathbf u$.

$\mathbf u$ can be any element in $\mathbb U$.

*Example*.
(Audition)
loudness.
(Gustation)
bitterness,
saltiness,
sourness,
sweetness,
umami,
metallic flavour,
fat flavour.
(Somatosensation)
pressure.
(Vision)
brighness.

**Definition** (Bipolar Intensity).
A bipolar intensity is a tuple $(\mathbb U, \preceq, \oplus)$.
- $(\mathbb U, \preceq)$ is a total order.
- $(\mathbb U, \oplus)$ is a monoid.
- If $\mathbf u\preceq \mathbf v$ then $\mathbf w \oplus \mathbf v\preceq \mathbf w \oplus \mathbf v$.
- If $\mathbf u\preceq \mathbf v$ then $\mathbf u \oplus \mathbf w \preceq \mathbf v \oplus \mathbf w$.

$\mathbf u, \mathbf v, \mathbf w$ can be any element in $\mathbb U$.

*Example*.
(Emotion)
anger,
fear,
happiness,
hunger,
thirst.
(Somatosensation)
coldness,
hotness,
orgasm,
pain.


**Definition** (Multipolar Intensity).
A multipolar intensity is a tuple $(\mathbb U, \oplus, \odot)$.
- $(\mathbb U, \oplus)$ is a monoid.
- $\odot: \mathbb R \times \mathbb U \to \mathbb U$ where there is a $1\in\mathbb R$ such that $1 \odot \mathbf u = \mathbf u$.
- $r \odot (\mathbf u \oplus \mathbf v) = (r \odot \mathbf u) \oplus (r \odot \mathbf v)$.
- $(r \oplus s)\odot \mathbf u = (r \odot \mathbf u) \oplus (s \odot \mathbf u)$.
- There are $\mathbf u_0, ..., \mathbf u_k \in \mathbb U$ such that
$$
\mathbb U
\subseteq
\left\{
    r_0 \odot \mathbf u_0 \oplus \cdots \oplus r_k \odot \mathbf u_k
    \Bigg|
    \sum_{i=0}^{k} r_i = 1
    \land
    0\leq r_0,...,r_k \in \mathbb R
\right\}
$$
$\mathbf u, \mathbf v$ can be any element in $\mathbb U$,
$r,s$ can be any element in $\mathbb R$,
and $k$ can be any element in $\mathbb N$.

*Example.*
(Audition)
timbre.
(Vision)
colour.

___

The three kind above, unipolar, bipolar, and multipolar, do not constitute an exhaustive taxonomy.

*Example*.
In audition, pitch is perceived in cents rather than Hertz.
There is no unique zero—neither as an extremum nor as an identity element—so a total order would be enough.

## Product

**Definition** (Product).

**Definition** (Valence).