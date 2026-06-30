import Mathlib

/-!
# Self-contained mathematical core of Steingrimsson (2016)

This file formalizes the self-contained mathematical content of the review article

R. Steingrimsson,
*"Subjective intensity: Behavioral laws, numerical representations, and behavioral
predictions in Luce's model of global psychophysics"*,
Journal of Mathematical Psychology 75 (2016), 205–217.

The article is a review of R. Duncan Luce's program for a unified axiomatic theory
of psychophysical intensity.  Much of its formal content (Narens' commutative
property, cross-dimensional commutativity, and Torgerson's conjecture) is already
formalized in the companion files
`RequestProject.RatioMagnitudeEstimation` (Narens 1996),
`RequestProject.TorgersonLuce` (Luce 2012b) and
`RequestProject.CrossDimensionScales` (Luce, Steingrimsson & Narens 2010).

The genuinely new, self-contained mathematical content of the review, formalized
here, is:

## 1. The p-additive representation and the three psychophysical forms (Section 2.3.1)

In the unary (1-D) theory the summation operation `⊙` is ordinary physical
addition, so the *p-additive representation* (Equation 26)

`ϕ (x + y) = ϕ x + ϕ y + δ · ϕ x · ϕ y`,  `δ ∈ {-1, 0, 1}`

is a functional equation in `ϕ`.  The point Steingrimsson highlights (the
"incompleteness of Hölder's (1901) theorem") is that, unlike in classical
physics where `δ = 0` is forced, all three values of `δ` admit a strictly
increasing solution.  The three solution families are:

* `δ = -1` : `ϕ(x) = 1 - e^{-κ x}` (`κ > 0`),
* `δ =  0` : `ϕ(x) = η x` (`η > 0`),
* `δ =  1` : `ϕ(x) = e^{λ x} - 1` (`λ > 0`).

We prove each of these solves the functional equation (`padditive_*`) and is
strictly increasing for positive parameters (`padditive_*_strictMono`).

## 2. The rating-scale representations (Section 2.4.2)

For a partition of the interval `(x, y)` into `n` "equal" parts, the first `m`
of them end at the signal `e` characterized by *equisection* (Equation 27):

`(n - m)·(ψ e - ψ x) = m·(ψ y - ψ e)  ⇔  ψ e = (m/n)·(ψ y - ψ x) + ψ x`.

We prove this equivalence (`equisection_iff`) and, substituting the power form
`ψ s = α s ^ β`, give the closed form `e = ((m/n)(y^β - x^β) + x^β)^{1/β}`
(`equisection_power`).

The *equal-ratio* (fractionation) prediction (Equation 28) places `r` so that
`W (m/n) = (ψ r - ψ x)/(ψ y - ψ x)`; substituting the power form yields
`r = (W(m/n)·y^β + (1 - W(m/n))·x^β)^{1/β}` (`fractionation_power`).

## 3. Functional form of the weighting function `W` (Equations 18–19)

Narens' multiplicative property (Equation 18) is equivalent to a power form for
the cognitive weighting function `W`.  The clean self-contained statements are
the multiplicativity of the power form (`power_multiplicative`) and its converse
(`W_multiplicative_power`): a strictly increasing, positive, multiplicative
weighting function on the positive reals is exactly a power function.
-/

namespace SubjectiveIntensity

open Real

/-! ## 1. The p-additive representation (unary case, Equation 26) -/

/-- The **p-additive functional equation** (Equation 26) for the unary summation
operation, where physical concatenation `⊙` is ordinary addition:
`ϕ (x + y) = ϕ x + ϕ y + δ · ϕ x · ϕ y`. -/
def PAdditive (φ : ℝ → ℝ) (δ : ℝ) : Prop :=
  ∀ x y : ℝ, φ (x + y) = φ x + φ y + δ * (φ x * φ y)

/-- The `δ = 0` solution `ϕ(x) = η x` of the p-additive equation (pure
additivity / power form with exponent `1`). -/
theorem padditive_zero (η : ℝ) : PAdditive (fun x => η * x) 0 := by
  intro x y; simp only; ring

/-- The `δ = 1` solution `ϕ(x) = e^{λ x} - 1` of the p-additive equation. -/
theorem padditive_one (lam : ℝ) :
    PAdditive (fun x => Real.exp (lam * x) - 1) 1 := by
  intro x y
  simp only
  rw [mul_add, Real.exp_add]; ring

/-- The `δ = -1` solution `ϕ(x) = 1 - e^{-κ x}` of the p-additive equation. -/
theorem padditive_neg_one (κ : ℝ) :
    PAdditive (fun x => 1 - Real.exp (-(κ * x))) (-1) := by
  intro x y
  simp only
  rw [mul_add, neg_add, Real.exp_add]; ring

/-- The `δ = 0` psychophysical form is strictly increasing for `η > 0`. -/
theorem padditive_zero_strictMono (η : ℝ) (h : 0 < η) :
    StrictMono (fun x : ℝ => η * x) := by
  intro a b hab; simp only; nlinarith

/-- The `δ = 1` psychophysical form is strictly increasing for `λ > 0`. -/
theorem padditive_one_strictMono (lam : ℝ) (h : 0 < lam) :
    StrictMono (fun x : ℝ => Real.exp (lam * x) - 1) := by
  intro a b hab
  simp only
  have : lam * a < lam * b := by nlinarith
  have := Real.exp_lt_exp.mpr this
  linarith

/-- The `δ = -1` psychophysical form is strictly increasing for `κ > 0`. -/
theorem padditive_neg_one_strictMono (κ : ℝ) (h : 0 < κ) :
    StrictMono (fun x : ℝ => 1 - Real.exp (-(κ * x))) := by
  intro a b hab
  simp only
  have : -(κ * b) < -(κ * a) := by nlinarith
  have := Real.exp_lt_exp.mpr this
  linarith

/-! ## 2. The rating-scale representations (Equations 27, 28) -/

/-- **Equisection equivalence** (Equation 27): the equal-interval characterization
of the boundary signal `e` of the first `m` of `n` subjectively equal parts of
`(x, y)` is equivalent to `ψ e` lying the fraction `m/n` of the way from `ψ x`
to `ψ y`.  Here `ψx, ψy, ψe` denote `ψ x, ψ y, ψ e`. -/
theorem equisection_iff (ψx ψy ψe m n : ℝ) (hn : n ≠ 0) :
    (n - m) * (ψe - ψx) = m * (ψy - ψe) ↔ ψe = (m / n) * (ψy - ψx) + ψx := by
  rw [div_mul_eq_mul_div, eq_comm (a := ψe)]
  constructor
  · intro h; field_simp; nlinarith [h]
  · intro h; field_simp at h; nlinarith [h]

/-- **Equisection, power form**: substituting `ψ s = α s ^ β` into the
equisection representation (Equation 27) gives the explicit boundary signal
`e = ((m/n)(y^β - x^β) + x^β)^{1/β}`.  The exponent `^` is `Real.rpow`. -/
theorem equisection_power (α β m n x y : ℝ) (hβ : β ≠ 0)
    (hbase : 0 ≤ (m / n) * (y ^ β - x ^ β) + x ^ β) :
    α * (((m / n) * (y ^ β - x ^ β) + x ^ β) ^ ((1 : ℝ) / β)) ^ β
      = (m / n) * (α * y ^ β - α * x ^ β) + α * x ^ β := by
  rw [← Real.rpow_mul hbase, one_div, inv_mul_cancel₀ hβ, Real.rpow_one]; ring

/-- **Fractionation, power form** (Equation 28): substituting `ψ s = α s ^ β`,
the equal-ratio signal `r = (w·y^β + (1-w)·x^β)^{1/β}`, with `w = W (m/n)`,
satisfies `w = (ψ r - ψ x)/(ψ y - ψ x)`.  The exponent `^` is `Real.rpow`. -/
theorem fractionation_power (α β w x y : ℝ) (hα : 0 < α) (hβ : β ≠ 0)
    (hbase : 0 ≤ w * y ^ β + (1 - w) * x ^ β) (hxy : x ^ β ≠ y ^ β) :
    (α * ((w * y ^ β + (1 - w) * x ^ β) ^ ((1 : ℝ) / β)) ^ β - α * x ^ β)
        / (α * y ^ β - α * x ^ β) = w := by
  rw [← Real.rpow_mul hbase, one_div, inv_mul_cancel₀ hβ, Real.rpow_one]
  rw [div_eq_iff]
  · ring
  · have hsub : y ^ β - x ^ β ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
    rw [show α * y ^ β - α * x ^ β = α * (y ^ β - x ^ β) by ring]
    exact mul_ne_zero (ne_of_gt hα) hsub

/-! ## 3. The weighting function `W`: power form (Equations 18–19) -/

/-- The power weighting function `W(p) = p^ω` satisfies Narens' multiplicative
property (Equation 18) in the form `W (p q) = W p · W q`. -/
theorem power_multiplicative (ω p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    (p * q) ^ ω = p ^ ω * q ^ ω :=
  Real.mul_rpow hp.le hq.le

/-
Helper: a monotone additive function `g : ℝ → ℝ` is linear, `g x = g 1 · x`.
This is the monotone case of Cauchy's functional equation.
-/
theorem monotone_additive_eq_mul {g : ℝ → ℝ}
    (hadd : ∀ x y : ℝ, g (x + y) = g x + g y) (hmono : Monotone g) :
    ∀ x : ℝ, g x = g 1 * x := by
  -- From `hadd` derive: g 0 = 0 (set x=y=0: g 0 = g 0 + g 0).
  have hg0 : g 0 = 0 := by
    simpa using hadd 0 0;
  -- For natural n, g (n•x) = n • g x; in particular for rationals q one gets g q = q * g 1 (prove g (q) = q * g 1 for all rationals q via g of integers and division).
  have hg_rational (q : ℚ) : g q = q * g 1 := by
    -- By induction on $n$, we can show that $g(nx) = ng(x)$ for any integer $n$ and real $x$.
    have h_ind : ∀ n : ℤ, ∀ x : ℝ, g (n * x) = n * g x := by
      intro m x; induction m using Int.induction_on <;> simp_all +decide [ add_mul ] ;
      have := hadd ( ( -↑‹ℕ› - 1 ) * x ) x; ring_nf at *; linarith;
    have := h_ind q.num 1; have := h_ind q.den 1; simp_all +decide [ Rat.cast_def ] ;
    have := h_ind q.den ( q.num / q.den ) ; simp_all +decide [ mul_comm, mul_div_cancel₀, ne_of_gt q.pos ] ;
    grind +splitIndPred;
  by_cases h : g 1 = 0;
  · intro x; exact le_antisymm ( le_of_not_gt fun hx => by have := hmono ( show x ≤ ⌈x⌉ from Int.le_ceil _ ) ; have := hg_rational ⌈x⌉; norm_num at * ; nlinarith [ Int.le_ceil x ] ) ( le_of_not_gt fun hx => by have := hmono ( show x ≥ ⌊x⌋ from Int.floor_le _ ) ; have := hg_rational ⌊x⌋; norm_num at * ; nlinarith [ Int.floor_le x ] ) ;
  · -- For real x, suppose g x ≠ x * g 1; WLOG g x > x * g 1. Pick rational r with x < r and r * g 1 < g x (possible when g 1 > 0 by density); then monotonicity g x ≤ g r = r * g 1 contradicts. Symmetric for the other inequality.
    intros x
    by_contra h_contra
    by_cases h_pos : 0 < g 1;
    · cases' lt_or_gt_of_ne h_contra with h_contra h_contra;
      · cases' exists_rat_btwn ( show x > g x / g 1 from by rw [ gt_iff_lt ] ; rw [ div_lt_iff₀ h_pos ] ; linarith ) with q hq ; have := hg_rational q ; simp_all +decide [ mul_comm ];
        nlinarith [ hmono hq.2.le, hg_rational q, mul_div_cancel₀ ( g x ) h ];
      · cases' exists_rat_btwn ( show x < g x / g 1 from by rw [ lt_div_iff₀ h_pos ] ; linarith ) with q hq ; have := hg_rational q ; simp_all +decide [ mul_comm ];
        rw [ lt_div_iff₀ h_pos ] at hq ; nlinarith [ hmono hq.1.le, hg_rational q ];
    · exact h ( by linarith [ hmono zero_le_one ] )

/-
**Converse of Equation 18 / Equation 19**: a strictly increasing, positive,
multiplicative weighting function `W` on the positive reals is a power function
`W p = p ^ ω`.  Together with `power_multiplicative` this is the equivalence
"multiplicative property `⇔` power form" of the review.
-/
theorem W_multiplicative_power (W : ℝ → ℝ)
    (hpos : ∀ p : ℝ, 0 < p → 0 < W p)
    (hmono : StrictMonoOn W (Set.Ioi 0))
    (hmul : ∀ p q : ℝ, 0 < p → 0 < q → W (p * q) = W p * W q) :
    ∃ ω : ℝ, ∀ p : ℝ, 0 < p → W p = p ^ ω := by
  -- Set `ω := g 1` where `g(t) = log (W (exp t))`.
  obtain ⟨ω, hω⟩ : ∃ ω : ℝ, ∀ t : ℝ, Real.log (W (Real.exp t)) = ω * t := by
    -- Define g : ℝ → ℝ by `g t := Real.log (W (Real.exp t))`.
    set g : ℝ → ℝ := fun t => Real.log (W (Real.exp t));
    -- g is additive: g (s + t) = log (W (exp (s+t))) = log (W (exp s * exp t)) = log (W (exp s) * W (exp t)) = log (W (exp s)) + log (W (exp t)) = g s + g t.
    have hg_add : ∀ s t : ℝ, g (s + t) = g s + g t := by
      simp +zetaDelta at *;
      exact fun s t => by rw [ ← Real.log_mul ( ne_of_gt ( hpos _ ( Real.exp_pos _ ) ) ) ( ne_of_gt ( hpos _ ( Real.exp_pos _ ) ) ), ← hmul _ _ ( Real.exp_pos _ ) ( Real.exp_pos _ ), Real.exp_add ] ;
    -- g is monotone: if s ≤ t then exp s ≤ exp t (Real.exp_le_exp), both positive, so since hmono is StrictMonoOn on Set.Ioi 0 we get W (exp s) ≤ W (exp t) (use hmono.monotoneOn or handle equality case), and Real.log is monotone on positives, giving g s ≤ g t.
    have hg_mono : Monotone g := by
      exact fun s t hst => Real.log_le_log ( hpos _ ( Real.exp_pos _ ) ) ( hmono.le_iff_le ( Real.exp_pos _ ) ( Real.exp_pos _ ) |>.2 ( Real.exp_le_exp.2 hst ) );
    exact ⟨ g 1, fun t => by linarith [ monotone_additive_eq_mul hg_add hg_mono t ] ⟩;
  use ω; intro p hp; specialize hω ( Real.log p ) ; rw [ Real.exp_log hp ] at hω; rw [ ← Real.exp_log ( hpos p hp ), hω, Real.rpow_def_of_pos hp ] ; rw [ mul_comm ];

end SubjectiveIntensity