import Mathlib

/-!
# Homeostatic reinforcement learning: basic definitions

Formalization of the core definitions of

  M. Keramati and B. Gutkin, *Homeostatic reinforcement learning for integrating reward
  collection and physiological stability*, eLife 2014;3:e04811.

The homeostatic space is `ι → ℝ` (one coordinate per physiologically regulated variable).
`Hstar` denotes the homeostatic setpoint `H*` and `H` the current internal state.

* Equation (1): the drive `D(H) = (∑ i, |h*ᵢ - hᵢ| ^ n) ^ (1/m)`.
* Equation (2): the primary reward `r(H, K) = D(H) - D(H + K)`.

Real exponents are used throughout (`Real.rpow`), matching the paper where `m` and `n`
are free real parameters (the paper's behavioural analysis assumes `n > m > 1`).
-/

namespace HRL

open scoped BigOperators

variable {ι : Type*} [Fintype ι]

/-- The drive function of Equation (1):
`D(H) = (∑ i, |h*ᵢ - hᵢ| ^ n) ^ (1/m)`, the (generalized) distance of the internal state
`H` from the setpoint `Hstar`. -/
noncomputable def drive (m n : ℝ) (Hstar H : ι → ℝ) : ℝ :=
  (∑ i, |Hstar i - H i| ^ n) ^ (1 / m)

/-- The primary reward of Equation (2): the drive reduction caused by an outcome `K`,
`r(H, K) = D(H) - D(H + K)`. -/
noncomputable def reward (m n : ℝ) (Hstar H K : ι → ℝ) : ℝ :=
  drive m n Hstar H - drive m n Hstar (H + K)

lemma reward_def (m n : ℝ) (Hstar H K : ι → ℝ) :
    reward m n Hstar H K = drive m n Hstar H - drive m n Hstar (H + K) := rfl

/-- The drive is always nonnegative. -/
lemma drive_nonneg (m n : ℝ) (Hstar H : ι → ℝ) : 0 ≤ drive m n Hstar H := by
  unfold drive; positivity

/-- At the setpoint the drive vanishes (`D(H*) = 0`), provided `m ≠ 0` and `n > 0`. -/
lemma drive_self (m n : ℝ) (hm : m ≠ 0) (hn : 0 < n) (Hstar : ι → ℝ) :
    drive m n Hstar Hstar = 0 := by
  unfold drive
  simp [Real.zero_rpow (by positivity : n ≠ 0), Real.zero_rpow (inv_ne_zero hm)]

/-- The drive vanishes exactly at the setpoint. -/
lemma drive_eq_zero_iff (m n : ℝ) (hm : m ≠ 0) (hn : 0 < n) (Hstar H : ι → ℝ) :
    drive m n Hstar H = 0 ↔ H = Hstar := by
  unfold drive
  rw [Real.rpow_eq_zero_iff_of_nonneg (by positivity)]
  constructor
  · rintro ⟨hsum, -⟩
    have hall := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => by positivity)).1 hsum
    funext i
    have hi := hall i (Finset.mem_univ i)
    rw [Real.rpow_eq_zero_iff_of_nonneg (abs_nonneg _)] at hi
    have := abs_eq_zero.1 hi.1
    linarith
  · rintro rfl
    refine ⟨?_, one_div_ne_zero hm⟩
    simp [Real.zero_rpow (by positivity : n ≠ 0)]

/-- For `n = 2` and `m = 1` the drive is the squared Euclidean distance to the setpoint. -/
lemma drive_one_two (Hstar H : ι → ℝ) :
    drive 1 2 Hstar H = ∑ i, (Hstar i - H i) ^ 2 := by
  unfold drive
  rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num]
  simp [sq_abs]

end HRL
