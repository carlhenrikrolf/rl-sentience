import RLSentience.Psychlib.DriveReduction.Basic

/-!
# Hyper-palatability: Equation (11) and the identities (S6), (S7)

Formalization of the "Hyper-palatability effect" section of 'Materials and methods' of
Keramati & Gutkin (eLife 2014;3:e04811).

Equation (11) augments the drive-reduction reward by a drive-independent palatability
term `T ≥ 0`:  `r(H_t, K_t) = D(H_t) - D(H_t + K_t) + T`.

For the special case of a quadratic drive (`n = 2`, `m = 1`, so `D(H) = (H - H*)²`) the
paper derives two equivalent readings of the term `T`, in a one-dimensional homeostatic
space:

* (S6) it shifts the setpoint from `H*` to `H* + T / (2K_t)`;
* (S7) it makes the internal state look under-estimated by `T / (2K_t)` units.
-/

namespace HRL

open scoped BigOperators

variable {ι : Type*} [Fintype ι]

/-- Equation (11): the drive-reduction reward augmented by a drive-independent
palatability term `T` (`T > 0` for hyper-palatable food, `T = 0` for normal food). -/
noncomputable def rewardPalatable (m n T : ℝ) (Hstar H K : ι → ℝ) : ℝ :=
  reward m n Hstar H K + T

/-- **Equation (S6)**: in a one-dimensional homeostatic space with quadratic drive, the
palatability term `T` is equivalent to shifting the setpoint to `H* + T / (2K)`. -/
theorem S6 (T k h hstar : ℝ) (hk : k ≠ 0) :
    rewardPalatable 1 2 T (fun _ : Fin 1 => hstar) (fun _ => h) (fun _ => k) =
      (h - (hstar + T / (2 * k))) ^ 2 - (h + k - (hstar + T / (2 * k))) ^ 2 := by
  unfold rewardPalatable reward drive
  rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num]
  simp [sq_abs]
  field_simp
  ring

/-- **Equation (S6)**, stated as an identity between reward functions: the palatable
reward with setpoint `H*` equals the plain drive-reduction reward of a system whose
setpoint is `H* + T / (2K)`. -/
theorem S6_setpoint_shift (T k h hstar : ℝ) (hk : k ≠ 0) :
    rewardPalatable 1 2 T (fun _ : Fin 1 => hstar) (fun _ => h) (fun _ => k) =
      reward 1 2 (fun _ : Fin 1 => hstar + T / (2 * k)) (fun _ => h) (fun _ => k) := by
  unfold rewardPalatable reward drive
  rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num]
  simp [sq_abs]
  field_simp
  ring

/-- **Equation (S7)**: equivalently, the palatability term `T` is equivalent to
under-estimating the internal state by `T / (2K)` units. -/
theorem S7 (T k h hstar : ℝ) (hk : k ≠ 0) :
    rewardPalatable 1 2 T (fun _ : Fin 1 => hstar) (fun _ => h) (fun _ => k) =
      ((h - T / (2 * k)) - hstar) ^ 2 - ((h - T / (2 * k)) + k - hstar) ^ 2 := by
  unfold rewardPalatable reward drive
  rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num]
  simp [sq_abs]
  field_simp
  ring

/-- **Equation (S7)**, stated as an identity between reward functions: the palatable
reward at internal state `H` equals the plain drive-reduction reward at the
under-estimated internal state `H - T / (2K)`. -/
theorem S7_state_underestimation (T k h hstar : ℝ) (hk : k ≠ 0) :
    rewardPalatable 1 2 T (fun _ : Fin 1 => hstar) (fun _ => h) (fun _ => k) =
      reward 1 2 (fun _ : Fin 1 => hstar) (fun _ => h - T / (2 * k)) (fun _ => k) := by
  unfold rewardPalatable reward drive
  rw [show ((2:ℝ)) = ((2:ℕ):ℝ) by norm_num]
  simp [sq_abs]
  field_simp
  ring

end HRL
