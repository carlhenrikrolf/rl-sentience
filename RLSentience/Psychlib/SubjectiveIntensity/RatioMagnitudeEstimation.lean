import Mathlib

/-!
# A Theory of Ratio Magnitude Estimation (Louis Narens, 1996)

This file formalizes the self-contained *behavioral* core of Louis Narens'
"A Theory of Ratio Magnitude Estimation" (Journal of Mathematical Psychology 40,
109–129, 1996).

## Setting

Following the paper, `X` is a (nonempty) set of stimuli presented to a subject,
and the subject's magnitude–estimation behavior is recorded as a set `E` of
ordered triples `(x, p, t)`, here represented as a relation
`E : X → ℝ → X → Prop`.  The intended reading of `E x p t` (written `(x, p, t) ∈ E`
in the paper) is that the subject, using `t` as modulus, judges stimulus `x`
to be "`p` times" stimulus `t`.

In the paper the numeral slot `p` ranges over the positive integers `I⁺` in the
behavioral conventions (Convention 2) and over the positive reals `R⁺` in
Definition 1.  Since none of the elementary arguments here depend on the numerals
being integral (this is explicitly noted in the paper, Subsection 3.5 on
"Generalized Ratio Magnitude Estimation"), we use real numerals `p : ℝ`
uniformly; all results specialize to integral numerals.

## Main results formalized

* `MultiplicativeProperty` — Definition 1.
* `CommutativeProperty` — Definition 2.
* `MultiplicativeClosure` — Axiom 9 (the "Multiplicative Property" closure axiom).
* `stevens_multiplicative` — **Theorem 1**: Stevens' Assumptions (a ratio scale of
  representing functions, with `φ z z = 1`) imply the multiplicative property.
* `multiplicativeClosure_implies_commutative` — the paper's remark
  "Note that Axiom 9 implies Axiom 4", i.e. the multiplicative closure axiom
  (together with the uniqueness part of Axiom 2) implies the commutative property.
* `multiplicative_implies_commutative` — the commutative property is *weaker than*
  the multiplicative property: in the presence of the structural conditions of
  Axiom 2 (totality and uniqueness), the multiplicative property (Definition 1)
  implies the commutative property (Definition 2).
* `stevens_multiplicativeClosure`, `stevens_numeralUnique`,
  `multiplicativeClosure_implies_multiplicative` — auxiliary results relating
  Stevens' Assumptions, Axiom 9, and Definition 1.

The deeper representational theorems of the paper (Theorems 2–19) rely on Cantor's
characterization of continua and the theory of scales of isomorphisms,
homogeneity and automorphisms of measurement structures, which are outside the
scope of this elementary formalization.
-/

namespace RatioMagnitudeEstimation

variable {X : Type*}

/-- **Definition 1 (multiplicative property).**
`E` has the multiplicative property iff for all stimuli and all numerals,
whenever `(x, p, t) ∈ E`, `(y, q, x) ∈ E` and `(y, r, t) ∈ E`, then `r = p · q`. -/
def MultiplicativeProperty (E : X → ℝ → X → Prop) : Prop :=
  ∀ (x t y : X) (p q r : ℝ), E x p t → E y q x → E y r t → r = p * q

/-- **Definition 2 (commutative property).**
`E` has the commutative property iff for all numerals `p, q` and all stimuli
`x, y, z, t, w`, if `(x, p, t) ∈ E`, `(z, q, x) ∈ E`, `(y, q, t) ∈ E` and
`(w, p, y) ∈ E`, then `z = w`. -/
def CommutativeProperty (E : X → ℝ → X → Prop) : Prop :=
  ∀ (x y z t w : X) (p q : ℝ),
    E x p t → E z q x → E y q t → E w p y → z = w

/-- **Axiom 9 (Multiplicative Property, closure form).**
For all numerals `p, q, r` and all stimuli `t, x, z`, if `(x, p, t) ∈ E`,
`(z, q, x) ∈ E` and `r = q · p`, then `(z, r, t) ∈ E`. -/
def MultiplicativeClosure (E : X → ℝ → X → Prop) : Prop :=
  ∀ (x t z : X) (p q r : ℝ), E x p t → E z q x → r = q * p → E z r t

/-- Uniqueness in the first (stimulus) coordinate: the existence-and-uniqueness
part of Statement 4 of Axiom 2.  For a fixed numeral `p` and modulus `t`, there is
at most one stimulus `z` with `(z, p, t) ∈ E`. -/
def FirstUnique (E : X → ℝ → X → Prop) : Prop :=
  ∀ (z w t : X) (p : ℝ), E z p t → E w p t → z = w

/-- Uniqueness in the numeral coordinate: for fixed stimuli `y, t` there is at
most one numeral `p` with `(y, p, t) ∈ E`. -/
def NumeralUnique (E : X → ℝ → X → Prop) : Prop :=
  ∀ (y t : X) (p p' : ℝ), E y p t → E y p' t → p = p'

/-- A totality condition matching the existence part of Axiom 2: if `(x, p, t) ∈ E`
and `(z, q, x) ∈ E`, then `z` admits some numeral relative to the modulus `t`. -/
def Composable (E : X → ℝ → X → Prop) : Prop :=
  ∀ (x t z : X) (p q : ℝ), E x p t → E z q x → ∃ s : ℝ, E z s t

/-- **Stevens' theory of ratio magnitude estimation.**

For each modulus `t`, the experimenter constructs a representing function
`φ t : X → ℝ`.  Stevens' Assumptions state that the family `{φ t}` lies in a single
*ratio scale*: each `φ t` is positive valued, the modulus is normalized so that
`φ z z = 1` for all `z`, and any two members of the family differ by a positive
real factor (Stevens' Assumption 2: `φ x = u · φ t` for some `u > 0`). -/
structure StevensSetup (X : Type*) where
  /-- `φ t x` is the subject's numerical estimate of `x` using modulus `t`. -/
  φ : X → X → ℝ
  /-- Representing functions take values in the positive reals. -/
  pos : ∀ t x, 0 < φ t x
  /-- The modulus is assigned subjective intensity `1` (the hypothesis
  `φ z z = 1` of Theorem 1). -/
  modulus : ∀ z, φ z z = 1
  /-- Stevens' Assumption 2: each `φ x` is a positive multiple of each `φ t`. -/
  ratio : ∀ t x, ∃ u : ℝ, 0 < u ∧ ∀ y, φ x y = u * φ t y

/-- The data set generated by a Stevens setup: `(x, p, t) ∈ E` iff `φ t x = p`. -/
def StevensSetup.E (S : StevensSetup X) (x : X) (p : ℝ) (t : X) : Prop :=
  S.φ t x = p

/-- **Theorem 1.** Under Stevens' Assumptions (with `φ z z = 1` for all `z`),
the generated data set `E` has the multiplicative property. -/
theorem stevens_multiplicative (S : StevensSetup X) :
    MultiplicativeProperty S.E := by
  intro x t y p q r hp hq hr
  have h_eq : p = S.φ t x ∧ q = S.φ x y ∧ r = S.φ t y := by
    exact ⟨ hp.symm, hq.symm, hr.symm ⟩;
  obtain ⟨ u, hu, hu' ⟩ := S.ratio t x;
  have := S.modulus x; simp_all +decide ;
  linear_combination -this * S.φ t y

/-- Stevens' Assumptions imply the multiplicative *closure* axiom (Axiom 9). -/
theorem stevens_multiplicativeClosure (S : StevensSetup X) :
    MultiplicativeClosure S.E := by
  intro x t z p q r hx hz hr
  obtain ⟨u, hu_pos, hu⟩ := S.ratio t x
  unfold StevensSetup.E at *
  have hxx := S.modulus x
  have e1 := hu x
  have e2 := hu z
  rw [hxx] at e1
  subst hr hx hz
  linear_combination (S.φ t z) * e1 - (S.φ t x) * e2

/-- The Stevens data set is functional in the numeral coordinate: a given pair of
stimuli determines at most one numeral. -/
theorem stevens_numeralUnique (S : StevensSetup X) :
    NumeralUnique S.E := by
  exact fun y t p p' hp hp' => by linarith [ hp.symm, hp'.symm ] ;

/-- **"Note that Axiom 9 implies Axiom 4".**  The multiplicative closure axiom
(Axiom 9), together with first-coordinate uniqueness (the uniqueness part of
Axiom 2), implies the commutative property (Axiom 4). -/
theorem multiplicativeClosure_implies_commutative
    (E : X → ℝ → X → Prop) (hU : FirstUnique E) (hClosure : MultiplicativeClosure E) :
    CommutativeProperty E := by
  grind +locals

/-- Under numeral uniqueness, the multiplicative closure axiom (Axiom 9) implies
the multiplicative property (Definition 1). -/
theorem multiplicativeClosure_implies_multiplicative
    (E : X → ℝ → X → Prop) (hN : NumeralUnique E) (hClosure : MultiplicativeClosure E) :
    MultiplicativeProperty E := by
  exact fun x t y p q r h1 h2 h3 => hN y t r ( q * p ) h3 ( hClosure x t y p q _ h1 h2 rfl ) ▸ mul_comm q p

/-- **The commutative property is weaker than the multiplicative property.**
In the presence of the structural conditions of Axiom 2 (first-coordinate
uniqueness and composability/totality), the multiplicative property
(Definition 1) implies the commutative property (Definition 2). -/
theorem multiplicative_implies_commutative
    (E : X → ℝ → X → Prop) (hU : FirstUnique E) (hC : Composable E)
    (hMul : MultiplicativeProperty E) :
    CommutativeProperty E := by
  grind +locals

end RatioMagnitudeEstimation