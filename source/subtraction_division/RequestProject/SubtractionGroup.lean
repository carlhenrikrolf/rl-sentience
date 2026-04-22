import Mathlib

/-!
# Groups axiomatized via subtraction

Instead of the usual group axioms on `(M, 0, +)`, we axiomatize a group via `(M, 0, -)` where
`-` behaves like subtraction (or division in multiplicative notation). The axioms are:

1. `ax_sub_self`: `a - a = 0`
2. `ax_double_neg`: `0 - (0 - a) = a`  (double negation)
3. `ax_right_cancel`: `(a - b) - (c - b) = a - c`  (right-translation invariance)

Addition is then *defined* as `a + b := a - (0 - b)`.

We show that these axioms are equivalent to the usual group axioms:
any group satisfies them (with `a - b := a + (-b)`), and conversely,
any structure satisfying them gives rise to a group.

If axiom 2 (`ax_double_neg`) is dropped, we lose the ability to invert elements and cannot
recover `+`; the resulting structure `(M, 0, -)` is no longer equivalent to a group — it would
correspond to a monoid-like structure (a "subtraction monoid" without guaranteed inverses).
-/

/-- A group axiomatized via subtraction: `(M, 0, -)` with three simple axioms. -/
structure SubtractionGroup (M : Type*) where
  /-- The identity element. -/
  e : M
  /-- The subtraction operation. -/
  sub : M → M → M
  /-- Axiom 1: Self-subtraction yields identity (1 variable). -/
  ax_sub_self : ∀ a : M, sub a a = e
  /-- Axiom 2: Double negation cancels (1 variable). -/
  ax_double_neg : ∀ a : M, sub e (sub e a) = a
  /-- Axiom 3: Right-translation invariance of subtraction (3 variables). -/
  ax_right_cancel : ∀ a b c : M, sub (sub a b) (sub c b) = sub a c

namespace SubtractionGroup

variable {M : Type*} (S : SubtractionGroup M)

/-- Negation: `-a := e - a` -/
def neg (a : M) : M := S.sub S.e a

/-- Addition: `a + b := a - (e - b) = a - (-b)` -/
def add (a b : M) : M := S.sub a (S.neg b)

-- ============================================================
-- Derived properties of subtraction
-- ============================================================

/-- `e - e = e` -/
lemma sub_e_e : S.sub S.e S.e = S.e := S.ax_sub_self S.e

/-
`-(a - b) = b - a`; set a := b in ax_right_cancel to get `e - (c - b) = b - c`.
    Then rename.
-/
lemma neg_sub (a b : M) : S.neg (S.sub a b) = S.sub b a := by
  have := S.ax_right_cancel b b a;
  rwa [ S.ax_sub_self ] at this

/-
`a - e = a`
-/
lemma sub_e (a : M) : S.sub a S.e = a := by
  obtain ⟨ e, sub, h ⟩ := S;
  rename_i h1 h2;
  -- Using the fact that $sub (sub e a) (sub a a) = sub (sub e a) e$ and $sub (sub e a) e = a$, we can conclude the proof.
  have h_sub : sub (sub e a) (sub a a) = sub (sub e a) e := by
    rw [ h ];
  grind

/-
`(a - b) - (e - b) = a`; from ax_right_cancel with c = e.
-/
lemma sub_sub_neg_right (a b : M) : S.sub (S.sub a b) (S.sub S.e b) = a := by
  rw [ S.ax_right_cancel, S.sub_e ]

-- ============================================================
-- Properties of the defined addition
-- ============================================================

/-- Left identity: `e + a = a` -/
lemma add_left_id (a : M) : S.add S.e a = a := by
  unfold add neg
  exact S.ax_double_neg a

/-
Right identity: `a + e = a`
-/
lemma add_right_id (a : M) : S.add a S.e = a := by
  convert S.ax_right_cancel a S.e S.e using 1;
  · simp +decide [ SubtractionGroup.add, SubtractionGroup.neg ];
    congr! 1;
    exact (sub_e S a).symm;
  · exact (sub_e S a).symm

/-- Left inverse: `(-a) + a = e` -/
lemma add_left_inv (a : M) : S.add (S.neg a) a = S.e := by
  unfold add neg
  exact S.ax_sub_self _

/-
Right inverse: `a + (-a) = e`
-/
lemma add_right_inv (a : M) : S.add a (S.neg a) = S.e := by
  -- From ax_right_cancel with c = a, we get `(a - b) - (a - b) = a - a = e`. This confirms that `sub a a = e` for all `a`.
  have h_sub_self : ∀ a, S.sub a a = S.e := by
    exact S.ax_sub_self;
  have := S.ax_double_neg;
  grind +locals

/-
Associativity: `(a + b) + c = a + (b + c)`

  Proof sketch:
  - Unfold to show LHS = sub (sub a (sub e b)) (sub e c)
    and RHS = sub a (sub (sub e c) b)
  - By ax_right_cancel with (p, q, r) = (sub e c, b, e):
    sub (sub (sub e c) b) (sub e b) = sub (sub e c) e = sub e c  ... (*)
  - So sub e c = sub (sub (sub e c) b) (sub e b)
  - Then LHS = sub (sub a (sub e b)) (sub (sub (sub e c) b) (sub e b))
  - By ax_right_cancel with common subtrahend (sub e b):
    = sub a (sub (sub e c) b) = RHS
-/
lemma add_assoc (a b c : M) : S.add (S.add a b) c = S.add a (S.add b c) := by
  -- By ax_right_cancel with (p, q, r) = (sub e c, b, e):
  have h1 : S.sub (S.sub (S.sub S.e c) b) (S.sub S.e b) = S.sub (S.sub S.e c) S.e := by
    exact S.ax_right_cancel _ _ _;
  convert S.ax_right_cancel _ _ _ using 1;
  swap;
  exact S.sub S.e b;
  unfold SubtractionGroup.add SubtractionGroup.neg;
  rw [ show S.sub S.e ( S.sub b ( S.sub S.e c ) ) = S.sub ( S.sub S.e c ) b from ?_ ];
  · rw [ h1, S.sub_e ];
  · convert S.neg_sub _ _ using 1

-- ============================================================
-- Building a Group instance from SubtractionGroup
-- ============================================================

/-- Every `SubtractionGroup` gives rise to a `Group`. -/
noncomputable def toGroup : Group M where
  mul := S.add
  mul_assoc := S.add_assoc
  one := S.e
  one_mul := S.add_left_id
  mul_one := S.add_right_id
  inv := S.neg
  inv_mul_cancel := S.add_left_inv

end SubtractionGroup

/-
============================================================
Every Group gives rise to a SubtractionGroup
============================================================

Every `Group` gives rise to a `SubtractionGroup` via `a ⊖ b := a * b⁻¹`.
-/
def Group.toSubtractionGroup (G : Type*) [Group G] : SubtractionGroup G where
  e := 1
  sub a b := a * b⁻¹
  ax_sub_self a := mul_inv_cancel a
  ax_double_neg a := by simp [inv_inv]
  ax_right_cancel a b c := by
    group

/-
============================================================
Round-trip: Group → SubtractionGroup → Group recovers original operations
============================================================

The addition recovered from a group's SubtractionGroup is the original multiplication.
-/
theorem roundtrip_mul (G : Type*) [Group G] (a b : G) :
    (Group.toSubtractionGroup G).add a b = a * b := by
      unfold Group.toSubtractionGroup;
      -- By definition of `add`, we have:
      simp [SubtractionGroup.add, SubtractionGroup.neg]

/-- The identity recovered from a group's SubtractionGroup is the original identity. -/
theorem roundtrip_one (G : Type*) [Group G] :
    (Group.toSubtractionGroup G).e = 1 := rfl

/-
The negation recovered from a group's SubtractionGroup is the original inverse.
-/
theorem roundtrip_inv (G : Type*) [Group G] (a : G) :
    (Group.toSubtractionGroup G).neg a = a⁻¹ := by
      exact one_mul _