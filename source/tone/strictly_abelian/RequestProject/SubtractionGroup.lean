import Mathlib

/-!
# Subtraction Groups: Axiomatizing Abelian Groups via Subtraction

An abelian group is usually axiomatized as `(M, 0, +)` with axioms for `+`.
We show it can equivalently be axiomatized as `(M, 0, ⊖)` with just **three axioms**
for a subtraction-like operation:

1. `a ⊖ 0 = a` (subtracting zero does nothing)
2. `a ⊖ a = 0` (self-subtraction yields zero)
3. `a ⊖ (b ⊖ c) = c ⊖ (b ⊖ a)` (the "swap" axiom)

Addition is then *defined* as `a + b := a ⊖ (0 ⊖ b)`, and negation as `-a := 0 ⊖ a`.

## The commutativity axiom

**Axiom 3 is the one that determines commutativity.** Setting `b = 0` in axiom 3 gives:
  `a ⊖ (0 ⊖ c) = c ⊖ (0 ⊖ a)`, i.e., `a + c = c + a`.

For a possibly non-abelian group, one would replace axiom 3 with the weaker:
  `a ⊖ (b ⊖ c) = (a ⊖ (0 ⊖ c)) ⊖ b`
which gives associativity but **not** commutativity.

## The monoid case

If elements do not have inverses (i.e., subtraction is not total or well-behaved),
the `+` side gives a commutative monoid, and the `⊖` side gives a structure related
to BCK-algebras or effect algebras in the literature. The key difference is that
axiom 2 (`a ⊖ a = 0`) and axiom 3 together force the existence of inverses,
so the three axioms as stated already guarantee a full group structure.
-/

/-- A subtraction group: an abelian group axiomatized via subtraction.
    Each axiom uses at most 3 variables. -/
class SubGrp (M : Type*) where
  /-- The identity element -/
  zero : M
  /-- The subtraction operation -/
  sub : M → M → M
  /-- Axiom 1: Subtracting zero does nothing -/
  sub_zero : ∀ a, sub a zero = a
  /-- Axiom 2: Self-subtraction yields zero -/
  sub_self : ∀ a, sub a a = zero
  /-- Axiom 3 (the swap axiom): Encodes both associativity and commutativity.
      This is the axiom that forces commutativity of the derived addition. -/
  sub_sub_swap : ∀ a b c, sub a (sub b c) = sub c (sub b a)

namespace SubGrp

variable {M : Type*} [s : SubGrp M]

/-- Negation derived from subtraction: `-a := 0 ⊖ a` -/
def neg (a : M) : M := s.sub s.zero a

/-- Addition derived from subtraction: `a + b := a ⊖ (0 ⊖ b)` -/
def add (a b : M) : M := s.sub a (neg b)

/-! ## Fundamental derived lemmas -/

/-
`a ⊖ b = -(b ⊖ a)`: subtraction is negation of reversed subtraction.
    Proof: specialize axiom 3 with `c := 0` and simplify using axiom 1.
-/
theorem sub_eq_neg_sub (a b : M) : s.sub a b = neg (s.sub b a) := by
  -- Apply the swap axiom with $c = 0$:
  have h_swap : s.sub a (s.sub b s.zero) = s.sub s.zero (s.sub b a) := by
    exact s.sub_sub_swap _ _ _;
  rwa [ s.sub_zero ] at h_swap

/-
Negation is an involution: `-(-a) = a`.
    Proof: unfold neg twice, apply `sub_sub_swap 0 0 a`, simplify.
-/
theorem neg_neg (a : M) : neg (neg a) = a := by
  convert s.sub_sub_swap s.zero s.zero a using 1;
  rw [ s.sub_self, s.sub_zero ]

/-
Negation of zero is zero.
    Proof: unfold neg, apply `sub_self`.
-/
theorem neg_zero : neg (s.zero : M) = s.zero := by
  exact s.sub_self _

/-
Negation reverses subtraction: `-(a ⊖ b) = b ⊖ a`.
    Proof: by `sub_eq_neg_sub` we have `a ⊖ b = -(b ⊖ a)`, apply neg to both sides
    and use `neg_neg`.
-/
theorem neg_sub (a b : M) : neg (s.sub a b) = s.sub b a := by
  unfold neg;
  rw [ s.sub_sub_swap, s.sub_zero ]

/-! ## The four abelian group axioms for the derived addition -/

/-
**Commutativity**: `a + b = b + a`.
    Follows directly from axiom 3 with `b := 0`:
    `a ⊖ (0 ⊖ c) = c ⊖ (0 ⊖ a)`.
-/
theorem add_comm' (a b : M) : add a b = add b a := by
  exact s.sub_sub_swap _ _ _

/-
**Right identity**: `a + 0 = a`.
    Proof: `add a 0 = a ⊖ neg 0 = a ⊖ 0 = a`.
-/
theorem add_zero' (a : M) : add a s.zero = a := by
  convert s.sub_zero a using 1;
  exact congr_arg _ ( s.sub_self _ )

/-
**Right inverse**: `a + (-a) = 0`.
    Proof: `add a (neg a) = a ⊖ neg(neg a) = a ⊖ a = 0`.
-/
theorem add_right_neg (a : M) : add a (neg a) = s.zero := by
  convert s.sub_self a using 1;
  exact congr_arg _ ( s.neg_neg a )

/-
Auxiliary: `(-a) ⊖ b = (-b) ⊖ a`.
    Proof: Both sides equal `-(a ⊖ (-b))` and `-(b ⊖ (-a))` respectively,
    which are equal by commutativity of add.
-/
theorem neg_sub_comm (a b : M) : s.sub (neg a) b = s.sub (neg b) a := by
  rw [ s.sub_eq_neg_sub, s.sub_eq_neg_sub ];
  convert s.sub_sub_swap _ _ _ using 1;
  grind +suggestions

/-
**Associativity**: `(a + b) + c = a + (b + c)`.

    Proof sketch:
    - LHS = `(a ⊖ neg b) ⊖ neg c`
    - Write `neg c = 0 ⊖ c`, apply `sub_sub_swap` to get `c ⊖ neg(a ⊖ neg b)`
    - Use `neg_sub` to get `c ⊖ (neg b ⊖ a)`
    - Apply `sub_sub_swap` again to get `a ⊖ (neg b ⊖ c)`
    - RHS = `a ⊖ neg(b ⊖ neg c) = a ⊖ (neg c ⊖ b)` by `neg_sub`
    - Reduce to showing `neg b ⊖ c = neg c ⊖ b`, which is `neg_sub_comm`.
-/
theorem add_assoc' (a b c : M) : add (add a b) c = add a (add b c) := by
  unfold add;
  grind +suggestions

/-! ## Equivalence with AddCommGroup -/

/-- Every `SubGrp` gives rise to an `AddCommGroup`. -/
noncomputable def toAddCommGroup : AddCommGroup M :=
  let _ : Zero M := ⟨s.zero⟩
  let _ : Add M := ⟨add⟩
  let _ : Neg M := ⟨neg⟩
  { add := add
    add_assoc := add_assoc'
    zero := s.zero
    zero_add := fun a => by show add s.zero a = a; rw [add_comm']; exact add_zero' a
    add_zero := add_zero'
    neg := neg
    neg_add_cancel := fun a => by show add (neg a) a = s.zero; rw [add_comm']; exact add_right_neg a
    add_comm := add_comm'
    nsmul := nsmulRec
    zsmul := zsmulRec }

end SubGrp

/-! ## Converse: every AddCommGroup is a SubGrp -/

/-- Every `AddCommGroup` satisfies the subtraction group axioms,
    where `sub a b := a + (-b)`. -/
def SubGrp.ofAddCommGroup (M : Type*) [AddCommGroup M] : SubGrp M where
  zero := 0
  sub a b := a + (-b)
  sub_zero a := by simp
  sub_self a := by simp
  sub_sub_swap a b c := by abel