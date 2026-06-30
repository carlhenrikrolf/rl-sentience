import Mathlib

/-!
# Torgerson's conjecture and Luce's magnitude production representation (Luce, 2012)

This file formalizes the mathematical core of

R. Duncan Luce, *"Torgerson's conjecture and Luce's magnitude production
representation imply an empirically false property"*, Journal of Mathematical
Psychology 56 (2012), 176–178.

This is a short result building on Narens' "A Theory of Ratio Magnitude
Estimation" (formalized in `RequestProject.RatioMagnitudeEstimation`).  Keeping
the two papers in separate files; the present result is mathematically
self-contained.

## Setting (Section 1–2 of the paper)

Signals are elements of a set `X` carrying a strictly increasing *psychophysical
ratio scale* `ψ : X → ℝ`.  Luce's magnitude production representation (equation
(1) of the paper) postulates a strictly increasing *cognitive distortion
function* `W` over the positive numbers and a reference signal `ρ` such that
`W p = (ψ (x_p) - ψ ρ) / (ψ x - ψ ρ)`.

For an interval `(x, y)` with `x < y` and integers `1 ≤ m ≤ n`:

* **Fractionation (2).**  The signal `r m n` that divides `(x, y)` "in the ratio
  `m/n`" satisfies
  `W (m / n) = (ψ (r m n) - ψ x) / (ψ y - ψ x)`.
* **Equisection (3).**  The signal `e m n` ending the first `m` of `n`
  subjectively equal subintervals satisfies
  `(n - m) (ψ (e m n) - ψ x) = m (ψ y - ψ (e m n))`.
* **Torgerson's conjecture (4).**  Respondents fail to distinguish subjective
  ratios from subjective differences, so `r m n = e m n` for all valid `m, n`.

## Main result

* `MagnitudeProduction.proposition1` — **Proposition 1**: under (2), (3), (4) the
  cognitive distortion function `W` is the identity on the half-open interval
  `(0, 1]`, i.e. `W p = p` for every `p ∈ (0, 1]`.

  (The paper states `W p = p` on the closed interval `[0, 1]`; the value at `0`
  is not determined by the hypotheses, since `W` is only constrained on the
  positive numbers, so the faithful provable statement uses `(0, 1]`.)

* `MagnitudeProduction.nat_ratio_identity` — the key step: `W (m / n) = m / n`
  for all integers `1 ≤ m ≤ n`.
* `MagnitudeProduction.rat_identity` — the same for every rational `q ∈ (0, 1]`.

The conclusion that `W` is the identity contradicts the empirically supported
fact that `W` is a non-identity (Prelec-type) function, which is the paper's
point: Torgerson's conjecture (4) is therefore empirically false.
-/

namespace TorgersonLuce

/-- The experimental setup of Luce (2012): a psychophysical scale `ψ`, a strictly
increasing cognitive distortion function `W`, an interval `(x, y)`, and the
fractionation/equisection signals, subject to fractionation (2), equisection (3)
and Torgerson's identity (4). -/
structure MagnitudeProduction (X : Type*) where
  /-- The strictly increasing psychophysical ratio scale. -/
  ψ : X → ℝ
  /-- The cognitive (number) distortion function. -/
  W : ℝ → ℝ
  /-- `W` is strictly increasing over the positive numbers. -/
  W_mono : StrictMonoOn W (Set.Ioi 0)
  /-- Left endpoint of the experimental interval. -/
  x : X
  /-- Right endpoint of the experimental interval. -/
  y : X
  /-- The interval is nondegenerate and correctly ordered (`x < y`, hence
  `ψ x < ψ y` since `ψ` is strictly increasing). -/
  hxy : ψ x < ψ y
  /-- Equisection signal: end of the first `m` of `n` equal subintervals. -/
  e : ℕ → ℕ → X
  /-- Fractionation signal: divides `(x, y)` in the ratio `m / n`. -/
  r : ℕ → ℕ → X
  /-- **Fractionation, equation (2).** -/
  fractionation : ∀ m n : ℕ, 1 ≤ m → m ≤ n →
    W ((m : ℝ) / n) = (ψ (r m n) - ψ x) / (ψ y - ψ x)
  /-- **Equisection, equation (3).** -/
  equisection : ∀ m n : ℕ, 1 ≤ m → m ≤ n →
    ((n : ℝ) - m) * (ψ (e m n) - ψ x) = (m : ℝ) * (ψ y - ψ (e m n))
  /-- **Torgerson's conjecture, equation (4):** ratios and differences coincide. -/
  torgerson : ∀ m n : ℕ, 1 ≤ m → m ≤ n → r m n = e m n

variable {X : Type*} (S : MagnitudeProduction X)

/-
**Key step.** From equisection (3) we get `(ψ (e m n) - ψ x)/(ψ y - ψ x) = m/n`,
and combining with fractionation (2) and Torgerson's identity (4) gives
`W (m / n) = m / n` for all integers `1 ≤ m ≤ n`.
-/
theorem nat_ratio_identity (m n : ℕ) (hm : 1 ≤ m) (hmn : m ≤ n) :
    S.W ((m : ℝ) / n) = (m : ℝ) / n := by
  rw [ S.fractionation, S.torgerson ];
  · rw [ div_eq_div_iff ] <;> try linarith [ S.hxy ];
    · linarith [ S.equisection m n hm hmn ];
    · exact Nat.cast_ne_zero.mpr ( by linarith );
  · exact hm;
  · grind;
  · exact hm;
  · grind

/-
`W` is the identity on positive rationals `≤ 1`.
-/
theorem rat_identity (q : ℚ) (hq0 : 0 < q) (hq1 : q ≤ 1) :
    S.W (q : ℝ) = (q : ℝ) := by
  obtain ⟨m, n, hm, hmn⟩ : ∃ m n : ℕ, 1 ≤ m ∧ m ≤ n ∧ (q : ℝ) = (m : ℝ) / n := by
    use q.num.natAbs, q.den;
    simp +decide [ abs_of_pos, hq0, Rat.cast_def ];
    exact ⟨ Nat.pos_of_ne_zero ( by aesop ), by rw [ ← Int.ofNat_le, Int.natAbs_of_nonneg ( Rat.num_nonneg.mpr hq0.le ) ] ; simpa [ Rat.le_iff ] using hq1 ⟩;
  rw [ hmn.2, nat_ratio_identity S m n hm hmn.1 ]

/-
**Proposition 1.** Under fractionation (2), equisection (3) and Torgerson's
conjecture (4), the cognitive distortion function `W` is the identity on `(0, 1]`.
-/
theorem proposition1 {p : ℝ} (hp : p ∈ Set.Ioc (0 : ℝ) 1) : S.W p = p := by
  by_contra h;
  -- Consider the two cases: $S.W p < p$ and $S.W p > p$.
  by_cases h_case : S.W p < p;
  · -- By `exists_rat_btwn` get a rational q with (lo:ℝ) < q < p.
    obtain ⟨q, hq⟩ : ∃ q : ℚ, max 0 (S.W p) < q ∧ q < p := by
      exact exists_rat_btwn ( max_lt ( hp.1 ) h_case ) |> fun ⟨ q, hq₁, hq₂ ⟩ => ⟨ q, hq₁, hq₂ ⟩;
    -- Then 0 < q (since lo ≥ 0) and q < p ≤ 1 so q ≤ 1, and q > S.W p (since q > lo ≥ S.W p).
    have hq_pos : 0 < q := by
      exact_mod_cast hq.1.trans_le' ( le_max_left _ _ )
    have hq_le_one : q ≤ 1 := by
      exact_mod_cast hq.2.le.trans hp.2
    have hq_gt_Wp : q > S.W p := by
      linarith [ le_max_right 0 ( S.W p ) ];
    -- By rat_identity, S.W (q:ℝ) = q.
    have hq_W : S.W (q : ℝ) = q := by
      convert TorgersonLuce.rat_identity S q hq_pos hq_le_one using 1;
    linarith [ S.W_mono ( show 0 < ( q : ℝ ) by positivity ) ( show 0 < p by linarith [ hp.1 ] ) hq.2 ];
  · by_cases h_case3 : p = 1;
    · have := nat_ratio_identity S 1 1 ; aesop;
    · -- Let $hi := \min 1 (S.W p)$. Then $p < hi$.
      set hi := min 1 (S.W p) with hhi
      have hhi_gt_p : p < hi := by
        grind;
      -- By `exists_rat_btwn` get rational $q$ with $p < q < hi$.
      obtain ⟨q, hq⟩ : ∃ q : ℚ, p < (q : ℝ) ∧ (q : ℝ) < hi := by
        exact exists_rat_btwn hhi_gt_p;
      -- Then $q < 1$ so $q \leq 1$, $q > p > 0$ so $0 < q$, and $q < S.W p$ (since $q < hi \leq S.W p$).
      have hq_le_one : (q : ℝ) ≤ 1 := by
        exact le_trans hq.2.le ( min_le_left _ _ )
      have hq_pos : 0 < (q : ℝ) := by
        linarith [ hp.1 ]
      have hq_lt_SWp : (q : ℝ) < S.W p := by
        exact lt_of_lt_of_le hq.2 ( min_le_right _ _ );
      -- By `rat_identity`, $S.W q = q$.
      have hq_SWq : S.W (q : ℝ) = (q : ℝ) := by
        convert TorgersonLuce.rat_identity S q _ _ <;> norm_cast at *;
      linarith [ S.W_mono ( show 0 < p by linarith [ hp.1 ] ) ( show 0 < ( q : ℝ ) by linarith ) hq.1 ]

end TorgersonLuce