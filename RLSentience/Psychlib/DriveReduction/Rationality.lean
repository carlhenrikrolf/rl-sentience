import RLSentience.Psychlib.DriveReduction.Basic

/-!
# Rationality of the theory: reward maximization = homeostatic stability

Formalization of the *Proposition* of the section "Rationality of the theory" in
'Materials and methods' of Keramati & Gutkin (eLife 2014;3:e04811), equations (S1)–(S5),
together with the paper's claim about the degenerate case `γ = 1` (main text, section
"Normative role of temporal discounting").

A *homeostatic trajectory* `p = {K₀, K₁, K₂, …}` is an ordered sequence of transitions in
the homeostatic space; starting from `H₀` the internal state evolves by `Hₜ₊₁ = Hₜ + Kₜ`.
`P(H₀)` is the set of trajectories that start at `H₀` and end at the setpoint `H*`.
-/

namespace HRL

open scoped BigOperators

variable {ι : Type*}

/-- A homeostatic trajectory: a finite ordered sequence of transitions `K₀, …, K_{w-1}`
in the homeostatic space (`length` is the number `w` of transitions; the values of `step`
beyond `length` are irrelevant). -/
structure Trajectory (ι : Type*) where
  /-- The number `w` of transitions of the trajectory. -/
  length : ℕ
  /-- The transitions `Kₜ` of the trajectory. -/
  step : ℕ → (ι → ℝ)

namespace Trajectory

variable (p : Trajectory ι) (H0 : ι → ℝ)

/-- The internal state after `t` transitions: `Hₜ = H₀ + ∑_{s<t} K_s`, i.e. the solution of
`Hₜ₊₁ = Hₜ + Kₜ`. -/
def state (t : ℕ) : ι → ℝ := H0 + ∑ s ∈ Finset.range t, p.step s

@[simp] lemma state_zero : p.state H0 0 = H0 := by
  simp [state]

lemma state_succ (t : ℕ) : p.state H0 (t + 1) = p.state H0 t + p.step t := by
  simp [state, Finset.sum_range_succ, add_assoc]

/-- The trajectory `p` reaches the setpoint `Hstar` from `H0`, i.e. `p ∈ P(H₀)`. -/
def Reaches (Hstar : ι → ℝ) : Prop := p.state H0 p.length = Hstar

/-- Equation (S1): the sum of discounted drives along the trajectory,
`SDD_p(H₀) = ∑_{t<w} γᵗ · D(Hₜ₊₁)`. -/
noncomputable def SDD (γ : ℝ) (D : (ι → ℝ) → ℝ) : ℝ :=
  ∑ t ∈ Finset.range p.length, γ ^ t * D (p.state H0 (t + 1))

/-- Equation (S2): the sum of discounted rewards along the trajectory,
`SDR_p(H₀) = ∑_{t<w} γᵗ · rₜ = ∑_{t<w} γᵗ · (D(Hₜ) - D(Hₜ₊₁))`. -/
noncomputable def SDR (γ : ℝ) (D : (ι → ℝ) → ℝ) : ℝ :=
  ∑ t ∈ Finset.range p.length, γ ^ t * (D (p.state H0 t) - D (p.state H0 (t + 1)))

end Trajectory

variable {γ : ℝ} {D : (ι → ℝ) → ℝ} {H0 : ι → ℝ}

/-- Telescoping identity underlying Equation (S5). -/
private lemma sum_telescope (γ : ℝ) (f : ℕ → ℝ) (w : ℕ) :
    ∑ t ∈ Finset.range w, γ ^ t * (f t - f (t + 1)) =
      f 0 - γ ^ w * f w + (γ - 1) * ∑ t ∈ Finset.range w, γ ^ t * f (t + 1) := by
  induction w with
  | zero => simp
  | succ w ih =>
      rw [Finset.sum_range_succ, ih, Finset.sum_range_succ (f := fun t => γ ^ t * f (t + 1))]
      ring

/-- Equation (S5): for a trajectory ending at the setpoint (where the drive vanishes),
`SDR_p(H₀) = D(H₀) + (γ - 1) · SDD_p(H₀)`. -/
theorem SDR_eq_add_sub_one_mul_SDD (p : Trajectory ι)
    (hend : D (p.state H0 p.length) = 0) :
    p.SDR H0 γ D = D H0 + (γ - 1) * p.SDD H0 γ D := by
  have h := sum_telescope γ (fun t => D (p.state H0 t)) p.length
  simp only [Trajectory.SDR, Trajectory.SDD]
  rw [h, hend, Trajectory.state_zero]
  ring

/-- The Proposition (S3), pairwise form: among trajectories that reach the setpoint, and
provided `γ < 1`, one trajectory has a smaller sum of discounted drives than another
exactly when it has a larger sum of discounted rewards. -/
theorem SDD_le_iff_SDR_ge (hγ : γ < 1) (p q : Trajectory ι)
    (hp : D (p.state H0 p.length) = 0) (hq : D (q.state H0 q.length) = 0) :
    p.SDD H0 γ D ≤ q.SDD H0 γ D ↔ q.SDR H0 γ D ≤ p.SDR H0 γ D := by
  rw [SDR_eq_add_sub_one_mul_SDD p hp, SDR_eq_add_sub_one_mul_SDD q hq]
  constructor
  · intro h
    have := mul_le_mul_of_nonpos_left h (by linarith : γ - 1 ≤ 0)
    linarith
  · intro h
    by_contra hlt
    push_neg at hlt
    have := mul_lt_mul_of_neg_left hlt (by linarith : γ - 1 < 0)
    linarith

/-- The Proposition (S3): for any initial state `H₀` and any `γ < 1`,
`argmin_{p ∈ P(H₀)} SDD_p(H₀) = argmax_{p ∈ P(H₀)} SDR_p(H₀)`.

Here `S` is any set of trajectories along which the drive vanishes at the end point
(e.g. `S = P(H₀)`, the trajectories from `H₀` to the setpoint `H*`). -/
theorem argmin_SDD_eq_argmax_SDR (hγ : γ < 1) (S : Set (Trajectory ι))
    (hS : ∀ p ∈ S, D (p.state H0 p.length) = 0) :
    {p ∈ S | ∀ q ∈ S, p.SDD H0 γ D ≤ q.SDD H0 γ D} =
      {p ∈ S | ∀ q ∈ S, q.SDR H0 γ D ≤ p.SDR H0 γ D} := by
  ext p
  simp only [Set.mem_setOf_eq]
  constructor
  · rintro ⟨hpS, hp⟩
    exact ⟨hpS, fun q hq => (SDD_le_iff_SDR_ge hγ p q (hS p hpS) (hS q hq)).1 (hp q hq)⟩
  · rintro ⟨hpS, hp⟩
    exact ⟨hpS, fun q hq => (SDD_le_iff_SDR_ge hγ p q (hS p hpS) (hS q hq)).2 (hp q hq)⟩

/-- The Proposition (S3), stated for `P(H₀)`, the set of homeostatic trajectories that
start at `H₀` and end at the setpoint `H*`, and for the drive function of Equation (1):
`argmin_{p ∈ P(H₀)} SDD_p(H₀) = argmax_{p ∈ P(H₀)} SDR_p(H₀)` whenever `γ < 1`. -/
theorem argmin_SDD_eq_argmax_SDR_drive [Fintype ι] {m n : ℝ} (hm : m ≠ 0) (hn : 0 < n)
    (hγ : γ < 1) (Hstar H0 : ι → ℝ) :
    {p ∈ {p : Trajectory ι | p.Reaches H0 Hstar} |
        ∀ q ∈ {p : Trajectory ι | p.Reaches H0 Hstar},
          p.SDD H0 γ (drive m n Hstar) ≤ q.SDD H0 γ (drive m n Hstar)} =
      {p ∈ {p : Trajectory ι | p.Reaches H0 Hstar} |
        ∀ q ∈ {p : Trajectory ι | p.Reaches H0 Hstar},
          q.SDR H0 γ (drive m n Hstar) ≤ p.SDR H0 γ (drive m n Hstar)} := by
  refine argmin_SDD_eq_argmax_SDR hγ _ fun p hp => ?_
  rw [show p.state H0 p.length = Hstar from hp]
  exact drive_self m n hm hn Hstar

/-- Without discounting (`γ = 1`) the sum of rewards telescopes: it depends only on the
initial and the final internal state, and not on the trajectory taken between them.
This is the paper's claim in "Normative role of temporal discounting". -/
theorem SDR_of_gamma_one (p : Trajectory ι) (D : (ι → ℝ) → ℝ) (H0 : ι → ℝ) :
    p.SDR H0 1 D = D H0 - D (p.state H0 p.length) := by
  have h := sum_telescope 1 (fun t => D (p.state H0 t)) p.length
  simp only [Trajectory.SDR]
  rw [h, Trajectory.state_zero]
  simp

/-- Consequence of the previous theorem: with `γ = 1`, the equivalence (S3) fails.
There are two trajectories from the same initial state to the same setpoint with the
*same* sum of discounted rewards but *different* sums of discounted drives, so that
maximizing reward no longer selects the homeostatically optimal trajectory. -/
theorem gamma_one_not_equivalent :
    ∃ (H0 Hstar : Fin 1 → ℝ) (p q : Trajectory (Fin 1)),
      p.Reaches H0 Hstar ∧ q.Reaches H0 Hstar ∧
      p.SDR H0 1 (drive 1 2 Hstar) = q.SDR H0 1 (drive 1 2 Hstar) ∧
      p.SDD H0 1 (drive 1 2 Hstar) < q.SDD H0 1 (drive 1 2 Hstar) := by
  refine ⟨fun _ => 1, fun _ => 0, ⟨1, fun _ _ => -1⟩, ⟨2, fun t _ => if t = 0 then 1 else -2⟩,
    ?_, ?_, ?_, ?_⟩
  · funext i
    simp [Trajectory.state]
  · funext i
    simp [Trajectory.state, Finset.sum_range_succ]
    norm_num
  all_goals
  · simp [Trajectory.state, Trajectory.SDD, Trajectory.SDR, Finset.sum_range_succ,
      drive_one_two]
    norm_num

end HRL
