import mathlib
open scoped BigOperators

namespace ReinforcementLearning

/- Expectation `𝔼_{a ∼ p} [f a]` of function `f` under probability mass function `p`.
∑' is an infinite sum hence the `noncomputable` keyword -/
noncomputable def PMF.expect {α : Type} (p : PMF α) (f : α → ℝ) : ℝ :=
  ∑' a, (p a).toReal * f a

/-- `𝔼_{a ∼ δ_x}[f a] = f x` if deterministic -/
theorem PMF.expect_pure {α : Type} (x : α) (f : α → ℝ) :
    PMF.expect (PMF.pure x) f = f x := by
  unfold expect  -- I don't understand these commands
  rewrite [tsum_eq_single x]
  · simp [PMF.pure_apply]
  · intro b hb
    simp [PMF.pure_apply, hb]

/-- Markov decision process -/
structure MDP where
  State : Type
  Action : Type
  P : State → Action → PMF State
  R : State → Action → ℝ
  discount : ℝ

/-- Agent -/
structure Agt (M : MDP) where
  π : M.State → PMF M.Action
  V : M.State → ℝ
  Q : M.State → M.Action → ℝ
  bellman_Q : ∀ s a, Q s a = M.R s a + M.discount * PMF.expect (M.P s a) V
  bellman_V : ∀ s, V s = PMF.expect (π s) (Q s)

def advantage (M : MDP) (agt : Agt M) (s : M.State) (a : M.Action) : ℝ :=
  agt.Q s a - agt.V s

/-- TODO: the TD error should be a random variable.
That is a consequence of r ~ R(s, .)
Making this adjustment probably means including an Agt.IsDetermistic def -/
def tdError (M : MDP) (agt : Agt M) (s : M.State) (a : M.Action)
    (s' : M.State) : ℝ :=
  M.R s a + M.discount * agt.V s' - agt.V s

/-- Advantage equals TD error in deterministic MDPs -/
def MDP.IsDeterministic (M : MDP) : Prop :=
  ∀ s a, ∃ s', M.P s a = PMF.pure s'

/-- Assume (h) that the expected next state in the MDP equals the actual next state
given a state–action pair.
Then the TD error equals the advantage. -/
theorem td_error_eq_advantage (M : MDP) (agt : Agt M)
    (s : M.State) (a : M.Action) (s' : M.State)
    (h : M.P s a = PMF.pure s') :
    tdError M agt s a s' = advantage M agt s a := by
  rw [tdError, advantage, agt.bellman_Q s a, h, PMF.expect_pure]

/-- Assume (hdet) that the MDP is deterministic.
Given a state–action pair, the TD error equals the advantage. -/
theorem td_error_eq_advantage_of_deterministic (M : MDP) (agt : Agt M)
    (hdet : M.IsDeterministic) (s : M.State) (a : M.Action) :
    ∃ s', tdError M agt s a s' = advantage M agt s a := by
  obtain ⟨s', h⟩ := hdet s a
  exact ⟨s', td_error_eq_advantage M agt s a s' h⟩

end ReinforcementLearning
