# Summary of changes for run 41314d61-590f-4748-ac7a-f79176b80663
Continuing the same line of research, I formalized the self-contained single-dimension mathematical core of the newly attached paper R. Duncan Luce, Ragnar Steingrimsson & Louis Narens, "Are Psychophysical Scales of Intensities the Same or Different When Stimuli Vary on Other Dimensions?" (Psychological Review, 2010), which builds on the magnitude-production representation already formalized in the project (Narens 1996 and Luce 2012).

The new work is in a new, self-contained file `RequestProject/CrossDimensionScales.lean` (namespace `CrossDimensionScales`), keeping each paper in its own file as before. The existing files are untouched.

Modeling (Representation 1 / Equation 2 of the paper): a structure `RatioProduction` packages an injective psychophysical ratio scale `ψ : X → ℝ`, a cognitive distortion function `W`, two reference signals `rPlus` (used for numbers `≥ 1`) and `rMinus` (used for numbers `< 1`), a magnitude-production map `prod` (with `prod a p` read as "`p` times `a`"), and the representation law `W p = (ψ (prod a p) − ψ (ref p)) / (ψ a − ψ (ref p))`, where `ref p` selects `rPlus`/`rMinus` by the sign of `p − 1`. Iterated production is `x_{p,q} = prod (prod x p) q`.

Results proved (all `sorry`-free, depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`):
- `psi_prod` — the linearized form of the representation (key algebraic step).
- `commutative_pos` — Proposition 1, Case 1: for `p, q ≥ 1`, production commutes, `x_{p,q} = x_{q,p}`.
- `commutative_neg` — Proposition 1, Case 2: for `p, q < 1`, production commutes.
- `commutative_mixed_of_ref_eq` — Proposition 1, Case 3 (forward direction): for `p ≥ 1 > q`, if `rPlus = rMinus` then production commutes.
- `reference_estimation` — Proposition 2 (Equation 7, in `ψ`-form): the reference signal is recovered from the data, `ψ rPlus = (τ·ψ x − ψ x_{p,q})/(τ − 1)` with `τ = W p · W q`; substituting a power-function scale gives the paper's Equation 7.

Faithfulness notes recorded in the file's docstring: (i) `ψ` is modeled as injective, matching the paper's strictly increasing scale (no order on the stimulus set is needed); (ii) for Case 3 the paper states an "iff", but the converse (commutativity ⇒ `rPlus = rMinus`) needs genericity assumptions not implied by the bare representation, so only the rigorous forward direction is proved, as noted in the docstring; (iii) the cross-frequency Propositions 3–4 are direct two-frequency restatements of the same algebra and were left to the single-dimension core. The whole project builds cleanly with `CrossDimensionScales.lean` compiling with no `sorry` and no warnings.

# Summary of changes for run df02527a-ca1d-43b9-adb4-dc18fa15e6d8
I formalized the mathematical core of the newly attached paper, R. Duncan Luce, "Torgerson's conjecture and Luce's magnitude production representation imply an empirically false property" (Journal of Mathematical Psychology 56 (2012), 176–178), which is a short result building on Narens (1996).

To keep results cleanly separated by paper, I put this work in a new, self-contained file `RequestProject/TorgersonLuce.lean`, leaving the existing Narens formalization in `RequestProject/RatioMagnitudeEstimation.lean` untouched. Each paper now lives in its own file, so future papers building on Narens can each get their own file in the same way.

What the new file contains (in namespace `TorgersonLuce`):
- `MagnitudeProduction`: a structure modeling Luce's experimental setup — a psychophysical ratio scale `ψ : X → ℝ`, a cognitive distortion function `W` that is strictly increasing on the positive numbers (`W_mono`), an interval `(x, y)` with `ψ x < ψ y`, the fractionation/equisection signals `r`, `e`, and the paper's three constraints: fractionation (equation 2), equisection (equation 3), and Torgerson's conjecture (equation 4, `r m n = e m n`).
- `nat_ratio_identity`: the key step — `W (m/n) = m/n` for all integers `1 ≤ m ≤ n`, obtained by combining equisection with fractionation under Torgerson's identity.
- `rat_identity`: the same identity for every rational `q ∈ (0,1]`.
- `proposition1`: the paper's Proposition 1 — under (2), (3), (4) the cognitive distortion function `W` is the identity on `(0,1]`, i.e. `W p = p` for all `p ∈ (0,1]`, proved by a density/strict-monotonicity squeeze argument.

A faithfulness note recorded in the file's docstring: the paper states the conclusion `W p = p` on the closed interval `[0,1]`, but the value at `0` is not determined by the hypotheses (`W` is only constrained on the positive numbers), so the provable, faithful statement uses the half-open interval `(0,1]`. As the paper observes, this forced identity contradicts the empirically supported non-identity (Prelec-type) form of `W`, which is precisely its point against Torgerson's conjecture.

The file builds cleanly with no `sorry` and no warnings, and `proposition1` depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

# Summary of changes for run 641249af-7b43-4d8e-b1a5-b95fa221053f
I formalized the self-contained behavioral core of Louis Narens' "A Theory of Ratio Magnitude Estimation" (Journal of Mathematical Psychology 40, 109–129, 1996), provided as `theory_of_ratio_magnitude_estimation.pdf`.

The work is in a new file, `RequestProject/RatioMagnitudeEstimation.lean`, which builds cleanly with no `sorry` and uses only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Magnitude-estimation data is modeled as a relation `E : X → ℝ → X → Prop`, where `E x p t` is the paper's triple `(x, p, t) ∈ E` (subject judges stimulus `x` to be "`p` times" stimulus `t` using modulus `t`). As the paper notes (Subsection 3.5), the elementary arguments do not depend on numerals being integral, so real numerals are used uniformly.

Definitions formalized:
- `MultiplicativeProperty` (Definition 1)
- `CommutativeProperty` (Definition 2)
- `MultiplicativeClosure` (Axiom 9, the multiplicative-property closure axiom)
- `FirstUnique`, `NumeralUnique`, `Composable` (the existence/uniqueness conditions of Axiom 2)
- `StevensSetup` (Stevens' Assumptions: a ratio scale of positive representing functions `φ t`, normalized by `φ z z = 1`, with each `φ x` a positive multiple of each `φ t`) and its generated data set `StevensSetup.E`.

Theorems proved:
- `stevens_multiplicative` — **Theorem 1**: Stevens' Assumptions imply the multiplicative property.
- `stevens_multiplicativeClosure` — Stevens' Assumptions imply Axiom 9.
- `stevens_numeralUnique` — the Stevens data set is functional in the numeral coordinate.
- `multiplicativeClosure_implies_commutative` — the paper's remark "Note that Axiom 9 implies Axiom 4": Axiom 9 plus first-coordinate uniqueness yields the commutative property.
- `multiplicativeClosure_implies_multiplicative` — under numeral uniqueness, Axiom 9 implies Definition 1.
- `multiplicative_implies_commutative` — the commutative property is weaker than the multiplicative property: with the structural conditions of Axiom 2 (uniqueness and totality), Definition 1 implies Definition 2.

Scope note: the deeper representational theorems of the paper (Theorems 2–19) rest on Cantor's characterization of continua and on the theory of scales of isomorphisms, homogeneity, and automorphisms of measurement structures, which are essentially absent from the available libraries; these were left out of this elementary formalization, which captures the paper's behavioral core with complete, machine-checked proofs.