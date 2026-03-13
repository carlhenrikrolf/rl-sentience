# Valence

Here, we use sentient experiences as a subset of conscious experiences.
In addition to being conscious,
1. some sentient experiences feel better than other, and
2. all sentient experiences feel positive, negative, or neutral.

We formalize the first property using a partial order.

**Definition** (Partial order).
A partial order is tuple $(\mathbb V,\preceq)$ with three axioms:
- *Reflexivity*.
$a\preceq a$.
- *Transitivity*.
If $a\preceq b$ and $b\preceq c$ then $a\preceq c$.
- *Antisymmetry*.
If $a\preceq b$ and $b\preceq a$ then $a=b$.

$a,b,c$ can be any element in $\mathbb V$.

Note that this does not mean all experiences are comparable.

We formalize the second property using a monoid where the identity element is used for the neutral point.

**Definition** (Monoid).
A monoid is tuple $(\mathbb V,\oplus)$ with three axioms:
- *Associativity*.
$(a\oplus b)\oplus c=a\oplus (b\oplus c)$.
- *Identity*.
There is a $0\in \mathbb V$ such that $0\oplus a = a \oplus 0 = a$.
0 is called the identity element.

$a,b,c$ can be any element in $\mathbb V$.

Note that a consequence of these axioms is that the identity element $0$ is unique and so is the inverse $\ominus$.

We refer to the value of a sentient experience as valence and define it by defining how $\preceq,\oplus,0$ interact.

**Definition** (Valence).
Valence is a tuple $(\mathbb V, \oplus, \preceq)$, where
$(\mathbb V,\oplus)$ is a group and
$(\mathbb V,\preceq)$ is a partial order with two axioms:
- *Left-invariance*.
If $a\preceq b$ then $c\oplus a\preceq c\oplus b$.
- *Right-invariance*.
If $a\preceq b$ then $a\oplus c\preceq b\oplus c$.

$a,b,c$ can be any element in $\mathbb V$.

Note that bittersweetness is baked into this definition as it is not a requirement that that $a\preceq 0$ or $0\preceq a$ (it could be neither).