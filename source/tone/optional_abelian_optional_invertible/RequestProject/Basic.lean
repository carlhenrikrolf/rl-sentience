/-
# Division-First Axiomatization of Groups

We axiomatize groups starting from division (or subtraction) rather than
multiplication (or addition). The structure `(M, 1, /)` is equipped with
axioms describing how `/` behaves, and multiplication is *derived* as
`a * b = a / (1 / b)`.

## Axioms

### Base axioms (the "division structure", without invertibility):
- `div_self`: `a / a = 1`                              (1 variable)
- `div_right_cancel`: `(a / c) / (b / c) = a / b`      (3 variables)
- `div_assoc'`: `(a / b) / c = a / (c / (1 / b))`      (3 variables)

### Invertibility axiom (upgrades to a group):
- `inv_involution`: `1 / (1 / a) = a`                   (1 variable)

### Commutativity axiom (upgrades to an abelian group):
- `mul_comm'`: `a / (1 / b) = b / (1 / a)`              (2 variables)

## Hierarchy

- `DivStructure` = {div_self, div_right_cancel, div_assoc'}
- `DivGroup`     = DivStructure + {inv_involution}         ≅ Group
- `DivAbGroup`   = DivGroup    + {mul_comm'}               ≅ CommGroup

When `inv_involution` is removed, one obtains a weaker algebraic structure
in which division is well-behaved but multiplication cannot be fully recovered.

## Interpretation

In both additive and multiplicative notation:

| Division axiom              | Additive reading (`/` = `−`, `1` = `0`)   | Multiplicative reading          |
|-----------------------------|--------------------------------------------|---------------------------------|
| `a / a = 1`                | `a − a = 0`                               | `a / a = 1`                    |
| `(a/c) / (b/c) = a/b`     | `(a−c) − (b−c) = a−b`                     | Right cancellation              |
| `(a/b) / c = a/(c/(1/b))` | `(a−b) − c = a − (c+b)`                   | Division-associativity          |
| `1/(1/a) = a`              | `−(−a) = a`  (double negation)             | Double inversion                |
| `a/(1/b) = b/(1/a)`       | `a+b = b+a`  (commutativity)               | Commutativity of multiplication |
-/

import Mathlib

/-! ## The base "division structure" (without invertibility) -/

/-- A `DivStructure` is a set with a distinguished element `1` and a binary
    operation `/` satisfying three axioms that capture the algebraic behaviour
    of division (or subtraction), but *without* the assumption that the
    "inversion" map `a ↦ 1 / a` is an involution.

    **Axioms** (each uses at most 3 variables):
    - `div_self`: `∀ a, a / a = 1`
    - `div_right_cancel`: `∀ a b c, (a / c) / (b / c) = a / b`
    - `div_assoc'`: `∀ a b c, (a / b) / c = a / (c / (1 / b))` -/
class DivStructure (M : Type*) extends One M, Div M where
  div_self : ∀ a : M, a / a = 1
  div_right_cancel : ∀ a b c : M, (a / c) / (b / c) = a / b
  div_assoc' : ∀ a b c : M, (a / b) / c = a / (c / (1 / b))

namespace DivStructure

variable {M : Type*} [DivStructure M]

-- Basic derived identities --

@[simp] lemma one_div_one : (1 : M) / 1 = 1 := div_self 1

/-- `1 / (a / b) = b / a` — the "inversion" map reverses division.
    Proof: set `a := c` in `div_right_cancel` to get `1 / (b / c) = c / b`. -/
lemma one_div_div (a b : M) : (1 : M) / (a / b) = b / a := by
  have h := div_right_cancel a b b
  rw [div_self] at h
  have h2 := div_right_cancel b a a
  rw [div_self] at h2
  -- h : 1 / (b / b) ... we actually need the right substitution
  -- From div_right_cancel a b a: 1/(b/a) = a/b ... no
  -- Let me just use the direct substitution: div_right_cancel c b c gives 1/(b/c) = c/b
  have key := div_right_cancel b a b
  rw [div_self] at key
  -- key : 1 / (a / b) = b / a
  exact key

/-- `(a / c) / 1 = a / c` — right identity for elements in the image of `/`.
    Proof: set `b := c` in `div_right_cancel` and simplify with `div_self`. -/
lemma div_one_of_div (a c : M) : (a / c) / (1 : M) = a / c := by
  have := div_right_cancel a c c
  rwa [div_self] at this

end DivStructure

/-! ## DivGroup: the division structure with invertibility -/

/-- A `DivGroup` is a `DivStructure` together with the *invertibility axiom*
    `1 / (1 / a) = a`, which says the map `a ↦ 1 / a` is an involution.

    This single additional axiom is what allows us to *define* multiplication
    as `a * b := a / (1 / b)` and recover a full group structure.
    Without it, multiplication cannot be reconstructed. -/
class DivGroup (M : Type*) extends DivStructure M where
  inv_involution : ∀ a : M, (1 : M) / ((1 : M) / a) = a

namespace DivGroup

variable {M : Type*} [DivGroup M]

@[simp] lemma one_div_one_div (a : M) : (1 : M) / ((1 : M) / a) = a :=
  inv_involution a

/-- `a / 1 = a` for all `a`.
    Proof: by `inv_involution`, `a = 1 / (1 / a)`, which has the form `x / y`.
    By `div_one_of_div`, `(x / y) / 1 = x / y`, so `a / 1 = a`. -/
lemma div_one (a : M) : a / (1 : M) = a := by
  have h1 := DivStructure.div_one_of_div (M := M) 1 ((1 : M) / a)
  rw [inv_involution] at h1
  exact h1

/-- Define multiplication from division: `a * b := a / (1 / b)`. -/
def mul' (a b : M) : M := a / ((1 : M) / b)

/-- Define inversion from division: `a⁻¹ := 1 / a`. -/
def inv' (a : M) : M := (1 : M) / a

-- Key properties of the derived multiplication --

/-- Right identity: `a * 1 = a`. -/
lemma mul'_one (a : M) : mul' a 1 = a := by
  unfold mul'
  rw [DivStructure.one_div_one, div_one]

/-- Left identity: `1 * a = a`. -/
lemma one_mul' (a : M) : mul' 1 a = a :=
  inv_involution a

/-- Left inverse: `a⁻¹ * a = 1`. -/
lemma inv'_mul' (a : M) : mul' (inv' a) a = 1 :=
  DivStructure.div_self _

/-- Associativity: `(a * b) * c = a * (b * c)`.
    Key step: apply `div_assoc'` and use `inv_involution` to simplify. -/
lemma mul'_assoc (a b c : M) : mul' (mul' a b) c = mul' a (mul' b c) := by
  unfold mul'
  -- LHS: (a / (1/b)) / (1/c)
  -- Apply div_assoc': = a / ((1/c) / (1/(1/b)))
  rw [DivStructure.div_assoc']
  -- Now 1/(1/b) = b by inv_involution
  rw [inv_involution]
  -- Goal: a / ((1/c) / b) = a / (1 / (b / (1/c)))
  -- By one_div_div: 1 / (b / (1/c)) = (1/c) / b
  rw [DivStructure.one_div_div]

/-- Construct a `Group` from a `DivGroup`. -/
noncomputable def toGroup : Group M := by
  letI : Mul M := ⟨mul'⟩
  letI : Inv M := ⟨inv'⟩
  exact Group.ofLeftAxioms mul'_assoc one_mul' inv'_mul'

end DivGroup

/-! ## DivAbGroup: abelian division group -/

/-- A `DivAbGroup` is a `DivGroup` with the additional axiom that the derived
    multiplication is commutative: `a / (1 / b) = b / (1 / a)`.

    The axioms for the *abelian* case are: `{div_self, div_right_cancel,
    div_assoc', inv_involution, mul_comm'}`, a strict superset of the
    *non-abelian* axioms `{div_self, div_right_cancel, div_assoc', inv_involution}`. -/
class DivAbGroup (M : Type*) extends DivGroup M where
  mul_comm' : ∀ a b : M, a / ((1 : M) / b) = b / ((1 : M) / a)

namespace DivAbGroup

variable {M : Type*} [DivAbGroup M]

/-- Construct a `CommGroup` from a `DivAbGroup`. -/
noncomputable def toCommGroup : CommGroup M := by
  letI := DivGroup.toGroup (M := M)
  exact CommGroup.mk fun a b => mul_comm' a b

end DivAbGroup

/-! ## Reverse direction: Group → DivGroup and CommGroup → DivAbGroup -/

/-- Every `Group` gives rise to a `DivStructure`. -/
instance Group.toDivStructure (G : Type*) [Group G] : DivStructure G where
  div_self := fun a => div_self' a
  div_right_cancel := fun a b c => div_div_div_cancel_right a b c
  div_assoc' := fun a b c => by
    simp only [div_eq_mul_inv, inv_inv, mul_inv_rev, mul_assoc, one_mul]

/-- Every `Group` gives rise to a `DivGroup` whose `/` is the group division. -/
instance Group.toDivGroup (G : Type*) [Group G] : DivGroup G where
  inv_involution := fun a => by simp [div_eq_mul_inv]

/-- Every `CommGroup` gives rise to a `DivAbGroup`. -/
instance CommGroup.toDivAbGroup (G : Type*) [CommGroup G] : DivAbGroup G where
  mul_comm' := fun a b => by simp [div_eq_mul_inv, mul_comm]

/-! ## Equivalence: the derived group operations match the originals -/

/-- When we start from a `Group`, derive a `DivGroup`, and then build a `Group`
    back, the multiplication agrees with the original. -/
theorem group_divGroup_mul_eq (G : Type*) [Group G] (a b : G) :
    @DivGroup.mul' G (Group.toDivGroup G) a b = a * b := by
  simp [DivGroup.mul', div_eq_mul_inv]

/-- The derived inverse agrees with the original. -/
theorem group_divGroup_inv_eq (G : Type*) [Group G] (a : G) :
    @DivGroup.inv' G (Group.toDivGroup G) a = a⁻¹ := one_div a

/-! ## Properties of the weak structure (DivStructure without invertibility)

When `inv_involution` is dropped, we still retain useful algebraic properties:
- Division has a right identity on its image: `(a / b) / 1 = a / b`
- The map `φ(a) = 1 / a` reverses division: `1 / (a / b) = b / a`
- `φ(1) = 1`: the identity is its own inverse
- Right cancellation: `(a / c) / (b / c) = a / b`
- Division-associativity: `(a / b) / c = a / (c / (1 / b))`

However, without `inv_involution`, we cannot show `a / 1 = a` for all `a`,
and thus cannot define a multiplication operation with a two-sided identity.
The map `φ(a) = 1 / a` is still an anti-homomorphism (reversing the order of
division), but it is not necessarily an involution. -/
