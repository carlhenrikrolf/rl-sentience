import Mathlib

/-!
# Commutativity in the magnitude-production model (Luce, Steingrimsson & Narens, 2010)

This file formalizes the self-contained mathematical core of the single-dimension
results of

R. Duncan Luce, Ragnar Steingrimsson, and Louis Narens,
*"Are Psychophysical Scales of Intensities the Same or Different When Stimuli
Vary on Other Dimensions? Theory With Experiments Varying Loudness and Pitch"*,
Psychological Review (2010).

It continues the line of `RequestProject.RatioMagnitudeEstimation` (Narens 1996)
and `RequestProject.TorgersonLuce` (Luce 2012); the present result is
mathematically self-contained.

## Setting (Representation 1 and Equation 2 of the paper)

Signals are elements of a set `X` carrying a strictly increasing (hence
injective) *psychophysical ratio scale* `ψ : X → ℝ`.  Magnitude production is a
map `prod : X → ℝ → X`, where `prod a p` is the signal the respondent produces
as "`p` times" the signal `a`.  Luce's (2004) magnitude-production
representation postulates a *cognitive distortion function* `W` over numbers and
two *reference signals* `rPlus` (used for `p ≥ 1`) and `rMinus` (used for
`p < 1`) such that, for every base signal `a` and number `p`,

`W p = (ψ (prod a p) - ψ (ref p)) / (ψ a - ψ (ref p))`,

where `ref p = rPlus` if `1 ≤ p` and `ref p = rMinus` otherwise.  Taking
`a = x` gives the paper's Equation 1; taking `a = prod x p` gives Equation 2,
the iterated production used to test commutativity.

We write `x_{p,q} := prod (prod x p) q` for the signal obtained by producing
"`p` times `x`" and then "`q` times" the result.

## Main results

* `RatioProduction.commutative_pos` — **Proposition 1, Case 1**: for `p, q ≥ 1`,
  `x_{p,q} = x_{q,p}`.
* `RatioProduction.commutative_neg` — **Proposition 1, Case 2**: for `p, q < 1`,
  `x_{p,q} = x_{q,p}`.
* `RatioProduction.commutative_mixed_of_ref_eq` — **Proposition 1, Case 3** (the
  forward direction): for `p ≥ 1 > q`, if the two reference signals coincide
  (`rPlus = rMinus`) then `x_{p,q} = x_{q,p}`.  The paper states this as an
  "iff"; the converse requires additional genericity assumptions not captured by
  the bare representation, so only the (rigorous) forward direction is proved
  here.
* `RatioProduction.reference_estimation` — **Proposition 2** (Equation 7, in
  `ψ`-form): the reference signal is determined by the data via
  `ψ rPlus = (τ ψ x - ψ x_{p,q}) / (τ - 1)` with `τ = W p · W q`.  Substituting a
  power-function scale `ψ s = α s ^ β` (Equation 4) and cancelling `α` yields
  Equation 7 of the paper, `rPlus ^ β = (x ^ β τ - x_{p,q} ^ β) / (τ - 1)`.
-/

namespace CrossDimensionScales

/-- The magnitude-production setup of Luce (2004): a strictly increasing (hence
injective) psychophysical scale `ψ`, a cognitive distortion `W`, two reference
signals, a production map, and the representation (Equation 1 / Equation 2). -/
structure RatioProduction (X : Type*) where
  /-- The psychophysical ratio scale. -/
  ψ : X → ℝ
  /-- `ψ` is injective (it is strictly increasing in the paper). -/
  ψ_inj : Function.Injective ψ
  /-- The cognitive (number) distortion function. -/
  W : ℝ → ℝ
  /-- Reference signal used when the number is `≥ 1`. -/
  rPlus : X
  /-- Reference signal used when the number is `< 1`. -/
  rMinus : X
  /-- Magnitude production: `prod a p` is produced as "`p` times" `a`. -/
  prod : X → ℝ → X
  /-- **Representation 1 / Equation 2.** -/
  representation : ∀ (a : X) (p : ℝ),
    W p = (ψ (prod a p) - ψ (if 1 ≤ p then rPlus else rMinus)) /
          (ψ a - ψ (if 1 ≤ p then rPlus else rMinus))

namespace RatioProduction

variable {X : Type*} (S : RatioProduction X)

/-- The reference signal selected by a number `p`: `rPlus` if `1 ≤ p`, else
`rMinus`. -/
noncomputable def ref (p : ℝ) : X := if 1 ≤ p then S.rPlus else S.rMinus

/-
**Key linearized form of the representation.**  When the base signal `a` is
distinct (in `ψ`-value) from the reference signal selected by `p`, the
representation can be solved for `ψ (prod a p)`.
-/
theorem psi_prod (a : X) (p : ℝ) (h : S.ψ a ≠ S.ψ (S.ref p)) :
    S.ψ (S.prod a p) = S.W p * (S.ψ a - S.ψ (S.ref p)) + S.ψ (S.ref p) := by
  have hne : S.ψ a - S.ψ (S.ref p) ≠ 0 := sub_ne_zero_of_ne h
  have hrep : S.W p = (S.ψ (S.prod a p) - S.ψ (S.ref p)) / (S.ψ a - S.ψ (S.ref p)) :=
    S.representation a p
  field_simp [hne] at hrep
  linarith [hrep]

/-
**Proposition 1, Case 1.**  For `p, q ≥ 1`, magnitude production commutes:
`x_{p,q} = x_{q,p}`.
-/
theorem commutative_pos (x : X) (p q : ℝ) (hp : 1 ≤ p) (hq : 1 ≤ q)
    (hx : S.ψ x ≠ S.ψ S.rPlus)
    (hxp : S.ψ (S.prod x p) ≠ S.ψ S.rPlus)
    (hxq : S.ψ (S.prod x q) ≠ S.ψ S.rPlus) :
    S.prod (S.prod x p) q = S.prod (S.prod x q) p := by
  apply S.ψ_inj;
  rw [ S.psi_prod, S.psi_prod, S.psi_prod, S.psi_prod ];
  · rw [ show S.ref p = S.rPlus from if_pos hp, show S.ref q = S.rPlus from if_pos hq ] ; ring;
  · unfold RatioProduction.ref; aesop;
  · rwa [ show S.ref p = S.rPlus from if_pos hp ];
  · rwa [ show S.ref p = S.rPlus from if_pos hp ];
  · unfold RatioProduction.ref; aesop;

/-
**Proposition 1, Case 2.**  For `p, q < 1`, magnitude production commutes:
`x_{p,q} = x_{q,p}`.
-/
theorem commutative_neg (x : X) (p q : ℝ) (hp : p < 1) (hq : q < 1)
    (hx : S.ψ x ≠ S.ψ S.rMinus)
    (hxp : S.ψ (S.prod x p) ≠ S.ψ S.rMinus)
    (hxq : S.ψ (S.prod x q) ≠ S.ψ S.rMinus) :
    S.prod (S.prod x p) q = S.prod (S.prod x q) p := by
  apply S.ψ_inj;
  rw [ S.psi_prod, S.psi_prod, S.psi_prod, S.psi_prod ];
  · rw [ show S.ref p = S.rMinus from if_neg ( not_le_of_gt hp ), show S.ref q = S.rMinus from if_neg ( not_le_of_gt hq ) ] ; ring;
  · rwa [ show S.ref q = S.rMinus from if_neg ( not_le.mpr hq ) ];
  · grind +locals;
  · rwa [ show S.ref p = S.rMinus from if_neg hp.not_ge ];
  · rwa [ show S.ref q = S.rMinus from if_neg ( not_le.mpr hq ) ]

/-
**Proposition 1, Case 3 (forward direction).**  For `p ≥ 1 > q`, if the two
reference signals coincide then magnitude production commutes.
-/
theorem commutative_mixed_of_ref_eq (x : X) (p q : ℝ) (hp : 1 ≤ p) (hq : q < 1)
    (href : S.rPlus = S.rMinus)
    (hx : S.ψ x ≠ S.ψ S.rPlus)
    (hxp : S.ψ (S.prod x p) ≠ S.ψ S.rPlus)
    (hxq : S.ψ (S.prod x q) ≠ S.ψ S.rPlus) :
    S.prod (S.prod x p) q = S.prod (S.prod x q) p := by
  -- Apply `psi_prod` to all four items.
  have h1 : S.ψ (S.prod (S.prod x p) q) = S.W q * (S.ψ (S.prod x p) - S.ψ S.rPlus) + S.ψ S.rPlus := by
    convert S.psi_prod ( S.prod x p ) q _ using 1; all_goals unfold RatioProduction.ref; aesop;
  have h2 : S.ψ (S.prod (S.prod x q) p) = S.W p * (S.ψ (S.prod x q) - S.ψ S.rPlus) + S.ψ S.rPlus := by
    grind +suggestions
  have h3 : S.ψ (S.prod x p) = S.W p * (S.ψ x - S.ψ S.rPlus) + S.ψ S.rPlus := by
    convert S.psi_prod x p _;
    · exact Eq.symm ( if_pos hp );
    · exact Eq.symm ( if_pos hp );
    · unfold RatioProduction.ref; aesop;
  have h4 : S.ψ (S.prod x q) = S.W q * (S.ψ x - S.ψ S.rPlus) + S.ψ S.rPlus := by
    grind +suggestions;
  exact S.ψ_inj ( by rw [ h1, h2, h3, h4 ] ; ring )

/-
**Proposition 2 (Equation 7, in `ψ`-form).**  With `τ = W p · W q` for
`p, q ≥ 1`, the reference signal's scale value is recovered from the data:
`ψ rPlus = (τ · ψ x - ψ x_{p,q}) / (τ - 1)`.
-/
theorem reference_estimation (x : X) (p q : ℝ) (hp : 1 ≤ p) (hq : 1 ≤ q)
    (hx : S.ψ x ≠ S.ψ S.rPlus)
    (hxp : S.ψ (S.prod x p) ≠ S.ψ S.rPlus)
    (htau : S.W p * S.W q ≠ 1) :
    S.ψ S.rPlus =
      (S.W p * S.W q * S.ψ x - S.ψ (S.prod (S.prod x p) q)) / (S.W p * S.W q - 1) := by
  grind +suggestions

end RatioProduction

end CrossDimensionScales