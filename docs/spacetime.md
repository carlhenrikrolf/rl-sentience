# Spacetime

<details>
<summary>
<b>Definition</b> (Inner Product Space).
</summary>

Let
$(\mathcal K, 0, +, 1, \cdot)$ be a field.
An *inner product space over $\mathcal K$* is a tuple
$(\mathcal V, 0, +, \cdot, \langle*\rangle)$.
*Origin*
$0 \in \mathcal V$.
*Addition*
$+: \mathcal V \times \mathcal V \to \mathcal V$,
$(p,q) \mapsto p+q$.
*Scalar multiplication*
$\cdot: \mathcal K \times \mathcal V \to \mathcal V$,
$(a, p) \mapsto a \cdot p$.
*Inner product*
$\langle*\rangle : \mathcal V \times \mathcal V \to \mathcal V$,
$(p,q) \mapsto \langle p * q \rangle$.

1. Associativity.
$p+(q+r) = (p+q)+r$.
1. Commutativity.
$p+q = q+p$.
1. Identity of addition.
$p+0 = p$
1. Inverse.
$p+(-p)=0$
for some $(-p)\in \mathcal V$.
1. Compatibility.
$a\cdot (b\cdot p) = (a \cdot b) \cdot p$
1. Identity of scalar multiplication.
$1\cdot p = p$.
1. Distributivity.
$a \cdot (p+q) = (a\cdot p) + (a\cdot q)$.
1. Distributivity with respect to field.
$(a+b) \cdot p = (a\cdot p) + (b\cdot p)$.

Inner product:

9. Conjugate symmetry.
$\langle p * q \rangle = \overline{\langle q * p \rangle}$.
1. Linearity.
$\langle (a\cdot p) + (b\cdot q), r\rangle = (a\cdot \langle p * r\rangle) + (b\cdot \langle q * r \rangle)$.
1. Positive definiteness.
$\langle p * p \rangle\geq 0$.

$p,q,r$ can be any members of $\mathcal V$.
$a,b$ can be any members of $\mathcal K$.

</details>

**Definition** (Subjective Space).
A *subjective space over $\mathcal K$* is a tuple
$(\mathcal X, 0, +, \cdot, \langle\rangle, *)$.
*Expectation*
$\langle\rangle : \mathcal X \to \mathcal K$,
$p \mapsto \langle p \rangle$.
*Dot product*
$* : \mathcal X^3 \times \mathcal X^3 \to \mathcal X$.
Define
$\| p \| \cdot \| p \| \coloneqq \langle p * p \rangle$.

1. Euclidean.
$$
\left\langle
  \begin{bmatrix}
    x \\
    y \\
    z
  \end{bmatrix}
  *
  \begin{bmatrix}
    x' \\
    y' \\
    z'
  \end{bmatrix}
\right\rangle
=
\langle x\cdot x' \rangle + \langle y\cdot y' \rangle + \langle z\cdot z' \rangle
$$
2. Constant. $\langle\langle p \rangle\rangle = \langle p \rangle$.
3. Triangle inequality
$\|\langle p \rangle \| \leq \langle \| p \| \rangle$
4. Monotonic.

See Halpern et al. for axiomatization of expectations.


**Definition** (Subjective Time).

1. $\langle * \rangle$ is an inner product.
2. $\langle p \rangle = p$.
3.
$$
\left\langle
  \begin{bmatrix}
    t \\
    0
  \end{bmatrix}
  *
  \begin{bmatrix}
    0 \\
    u
  \end{bmatrix}
\right\rangle
\propto \|t\| \cdot \|u\|
$$
4. If $t\geq 0$ and $u \geq 0$ then
$$
\left\langle
  \begin{bmatrix}
    t \\
    0
  \end{bmatrix}
  *
  \begin{bmatrix}
    0 \\
    u
  \end{bmatrix}
\right\rangle
\leq 0
$$

