# Spacetime

**Definition** (Ternary Order).
A ternary order is a tuple $(\mathcal M, \preceq)$
where ${\preceq} : \mathcal M \times \mathcal M \to [0,1]$ notated as $(\mathbf a, \mathbf b)  \mapsto \mathbf a \preceq \mathbf b$.

- Reflexivity.
$[ a \preceq  a]=\tfrac{1}{2}$.
- Totality.
$[ a \preceq  b] + [ b \preceq  a] = 1$.
- Transitivity.
If $[ a \preceq  b]\geq \tfrac{1}{2}$
and $[ b \preceq  c]\geq \tfrac{1}{2}$
then
$[ a \preceq  c]\geq \min \{ [ t \preceq  u], [ u \preceq  v]\}$.
- Antisymmetry.
$[c \preceq a]=[c \preceq b]$
if and only if
$a=b$.

$a,b,c$ can be any member of $\mathcal M$.

**Definition** (Timelike Order).
A timelike order is a tuple $(\mathcal T, n, \preceq)$, where
$n\in\mathbb N$ is the *dimension*,
and ${\preceq} : \mathcal T^n \times \mathcal T^n \to \{0,\frac{1}{2}, 1\}$.

- Ternary. $(\mathcal T, \preceq)$ is a ternary order
- Interval.[^fishburn]
If $[a \preceq b]\geq\tfrac{1}{2}$ and $[c \preceq d]\geq\tfrac{1}{2}$
then $[a \preceq d]\geq\tfrac{1}{2}$ or $[c \preceq d]\geq\tfrac{1}{2}$. ==CHECK==
- Product.
$[\mathbf a \preceq \mathbf b] = p$
with $p\in\{0,1\}$
if and only if
$[a_i \preceq b_i]\in\{\tfrac{1}{2}, p\}$
for all $i$
and $[a_j \preceq b_j] = p$
for some $j$.

$a,b,c,d$ can be any member of $\mathcal T$.
$\mathbf a, \mathbf b$ can be any member of $\mathcal T^n$.
$i,j$ are confined within $\{1,...,n\}$.




**Definition** (Spacelike Order).
A spacelike order is a tuple $(\mathcal X, m, \preceq)$
where $m\in\mathbb N$ is the *dimension*
and ${\preceq} : \mathcal X^m \times \mathcal X^m \to [0,1]$.
- Ternary.
$(\mathcal X, \preceq)$ is a ternary order.
- Product.
==TODO==


**Definition** (Metric Spacetime).
Metric spacetime is a tuple $(\mathcal X, \mathcal T, \mathbf e, d)$,
where $\mathbf e\in \mathcal T^2$ and $d: \mathcal X^3\mathcal T^2 \times \mathcal X^3 \mathcal T^2 \to \mathbb R$.
- Spacelike.
$(\mathcal X, 3, \preceq)$ is a spacelike.
- Timelike.
$(\mathcal T, 2, \preceq)$ is a timelike.
- $[\mathbf e \preceq \mathbf t]\geq \tfrac{1}{2}$
for all $\mathbf t \in \mathcal T^2$.
- Product. ==TODO==
- Distance.
$d$ is a distance function.
- If $d(\mathbf x, \mathbf y)=0$
then
$[\mathbf x \preceq \mathbf y ]=\tfrac{1}{2}$.
- If $d(\mathbf x, \mathbf y)=\infty$
then
$[\mathbf x \preceq \mathbf y]\in\{0,1\}$.

$\mathbf x, \mathbf y$ can be any member of $\mathcal X^3 \mathcal T^2$ such that $x_4=y_4$ and $x_5=y_5$.


**Definition** (Normed Spacetime).
Normed spacetime is a tuple $(\mathcal X, \mathcal T, \|\|, \ominus)$,
where $\|\|: \mathcal X^3\mathcal T^2 \to \mathbb R$
notated as $\mathbf a \mapsto \|\mathbf a\|$,
and ${\ominus} : \mathcal X^3\mathcal T^2 \times \mathcal X^3\mathcal T^2 \to \mathcal X^3\mathcal T^2 $
notated as $(\mathbf a, \mathbf b) \mapsto \mathbf a \ominus \mathbf b$.


[^fishburn]: Fishburn. 1970.