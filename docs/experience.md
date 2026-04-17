# Experience

**Definition** (Conscious Space).
Let $\psi$ be a psychological space coordinate and $\phi$ be a physical (Minkowski) space coordinate.
Let
$$
\psi
=
\begin{pmatrix}
x_1 & x_2 \\
y_1 & y_2 \\
z_1 & z_2 \\
t_1 & t_2 \\
u_1 & u_2 \\
\end{pmatrix}
\quad
\phi
=
\begin{pmatrix}
x \\
y \\
z \\
t \\
\end{pmatrix}
$$
Define the position inner product $\langle\cdot|\cdot\rangle_\mathrm{pos}$ as
$$
\langle \psi | \psi' \rangle_\mathrm{pos}
=
\frac{x_1+x_2}{2}\frac{x_1'+x_2'}{2}
+
\frac{y_1+y_2}{2}\frac{y_1'+y_2'}{2}
+
\frac{z_1+z_2}{2}\frac{z_1'+z_2'}{2}
$$
and overload with
$$
\langle \phi | \phi' \rangle_\mathrm{pos}
=
x x' + y y' + z z'
$$
Define the velocity inner product $\langle\cdot|\cdot\rangle_\mathrm{vel}$ as
$$
\langle\psi|\psi'\rangle_\mathrm{vel}
=
\frac{x_2 - x_1}{t_2-t_1}\frac{x_2' - x_1'}{t_2'-t_1'}
+
\frac{y_2 - y_1}{t_2-t_1}\frac{y_2' - y_1'}{t_2'-t_1'}
+
\frac{z_2 - z_1}{t_2-t_1}\frac{z_2' - z_1'}{t_2'-t_1'}
$$
and overload with
$$
\langle\phi|\phi'\rangle_\mathrm{vel}
=
\frac{\partial x}{\partial t}\frac{\partial x'}{\partial t'}
+
\frac{\partial y}{\partial t}\frac{\partial y'}{\partial t'}
+
\frac{\partial z}{\partial t}\frac{\partial z'}{\partial t'}
$$
Finally, define the standard inner product $\langle\cdot|\cdot\rangle_\mathrm{std}$ as
$$
\langle\phi|\phi'\rangle_\mathrm{std}
=
x_1 x_1' + y_1 y_1' + z_1 z_1' + t_1 t_1' + u_1 u_1'
+
x_2 x_2' + y_2 y_2' + z_2 z_2' + t_2 t_2' + u_2 u_2' 
$$
A space is a conscious space if it has homeomorphisms with the Minkowski space over $\langle\cdot|\cdot\rangle_\mathrm{pos}$ and $\langle\cdot|\cdot\rangle_\mathrm{vel}$ and over $\mathbb Z^{10}$ with $\langle\cdot|\cdot\rangle_\mathrm{std}$.


**Definition** (Humanlike Experience).
Humanlike experience is a tuple
$(\mathbb W, \mathbb V, \mathbb L, I,S,G)$.
- $I: \mathbb W \to \mathbb V$ where $I(w)=v$ means that the subjective intensity at $w$ are $v$.
- $S: 2^\mathbb W \to \{0,1\}$, where $S\{w_0,...,w_n\}=1$ means that $\{w_0,...,w_n\}$ is the boundary of the self.
- $G: 2^\mathbb W \to 2^\mathbb L$ where $G\{w_0,...,w_n\}=\{l_0,...,l_m\}$ means that $\{l_0,...,l_m\}$ are Gestalt labels to $\{w_0,...,w_n\}$.



**Definition** (Sentient Experience).
==Sentient experience is a superset of human experience with valence== 


## Appendix

**Definition** (Metric Space).
A metric space is a tuple $(\mathbb M, d)$.
- $d: \mathbb M \times \mathbb M \to \mathbb R$ is a distance.
- $d(x,x)=0$.
- Positivity. If $x \neq y$ then $d(x,y) \geq 0$.
- Triangle Inequality. $d(x,z) \leq d(x,y) + d(y,z)$.
- Symmetry. $d(x,y)=d(y,x)$.


**Definition** (Smoothing).
...