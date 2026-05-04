import Mathlib

/-!
# Division Groups

A group can be axiomatized using division (or subtraction) and an identity element alone,
without explicitly postulating multiplication (or addition) or inverse (or negation).

This file develops this "division group" axiomatization and proves its equivalence with
the standard group axioms.

## Axioms

**Non-Abelian (3 axioms, at most 3 variables each):**
1. `a / a = 1`  — self-division yields the identity
2. `a / 1 = a`  — dividing by the identity is the identity
3. `a / (b / c) = (a / (1 / c)) / b`  — division associativity

**Abelian (adds 1 axiom, with 2 variables):**
4. `a / b = (1 / b) / (1 / a)`  — commutativity of the induced multiplication

The non-Abelian axioms are a **strict subset** of the Abelian axioms.

## Recovered operations

Given a `DivGroup` structure `(M, 1, /)`, one recovers multiplication and inverse as:
* `a * b := a / (1 / b)`
* `a⁻¹  := 1 / a`

## Main results

* `DivGroup.toGroup` — every `DivGroup` gives rise to a `Group`
* `CommDivGroup.toCommGroup` — every `CommDivGroup` gives rise to a `CommGroup`
* `Group.toDivGroup` — every `Group` gives rise to a `DivGroup`
* `CommGroup.toCommDivGroup` — every `CommGroup` gives rise to a `CommDivGroup`
-/

/-- A group axiomatized via division and identity.

The three axioms are:
1. `div_self : a / a = 1`
2. `div_one  : a / 1 = a`
3. `div_div  : a / (b / c) = (a / (1 / c)) / b`
-/
class DivGroup (M : Type*) extends One M, Div M where
  div_self : ∀ a : M, a / a = 1
  div_one  : ∀ a : M, a / 1 = a
  div_div  : ∀ a b c : M, a / (b / c) = (a / (1 / c)) / b

/-- A commutative (Abelian) group axiomatized via division and identity.
The axioms are a strict superset of `DivGroup`, adding one commutativity axiom. -/
class CommDivGroup (M : Type*) extends DivGroup M where
  div_comm : ∀ a b : M, a / b = (1 / b) / (1 / a)

namespace DivGroup

variable {M : Type*} [DivGroup M]

/-! ### Derived lemmas -/

/-- Cancellation: `(a / (1 / b)) / b = a`. In group terms, `(a * b) / b = a`. -/
@[simp] lemma cancel_inv_div (a b : M) : (a / (1 / b)) / b = a := by
  have h := DivGroup.div_div a b b
  rw [DivGroup.div_self, DivGroup.div_one] at h
  exact h.symm

/-- Double cancellation: `(x / c) / (1 / c) = x`. In group terms, `(x / c) * c = x`.

Proof: let `w = x / (1 / (1 / c))`. Then `w / (1/c) = x` (by `cancel_inv_div`)
and `(w / (1/c)) / c = w` (by `cancel_inv_div`).
So `(x/c)/(1/c) = ((w/(1/c))/c)/(1/c) = w/(1/c) = x`. -/
@[simp] lemma cancel_div_inv (x c : M) : (x / c) / (1 / c) = x := by
  set w := x / (1 / (1 / c))
  have h1 : w / (1 / c) = x := cancel_inv_div x (1 / c)
  have h2 : (w / (1 / c)) / c = w := cancel_inv_div w c
  calc (x / c) / (1 / c)
      = ((w / (1 / c)) / c) / (1 / c) := by rw [h1]
    _ = w / (1 / c) := by rw [h2]
    _ = x := h1

/-- Double inverse: `1 / (1 / a) = a`. In group terms, `(a⁻¹)⁻¹ = a`. -/
@[simp] lemma one_div_one_div (a : M) : (1 : M) / ((1 : M) / a) = a := by
  have h := cancel_div_inv a a
  rw [DivGroup.div_self] at h
  exact h

/-- Right cancellation: `(a / c) / (b / c) = a / b`. -/
lemma div_div_cancel (a b c : M) : (a / c) / (b / c) = a / b := by
  rw [DivGroup.div_div, cancel_div_inv]

/-- Inverse of a quotient: `1 / (a / b) = b / a`. In group terms, `(a / b)⁻¹ = b / a`. -/
lemma one_div_div (a b : M) : (1 : M) / (a / b) = b / a := by
  rw [DivGroup.div_div, one_div_one_div]

/-! ### Mul and Inv from DivGroup -/

/-- Multiplication recovered from division: `a * b := a / (1 / b)`. -/
scoped instance instMul : Mul M where
  mul a b := a / (1 / b)

/-- Inverse recovered from division: `a⁻¹ := 1 / a`. -/
scoped instance instInv : Inv M where
  inv a := 1 / a

@[simp] lemma mul_eq_div_inv (a b : M) : a * b = a / (1 / b) := rfl
@[simp] lemma inv_eq_one_div (a : M) : a⁻¹ = 1 / a := rfl

/-! ### Group construction -/

private lemma mul_assoc' (a b c : M) : a * b * c = a * (b * c) := by
  simp only [mul_eq_div_inv]
  rw [one_div_div b (1 / c)]
  exact (DivGroup.div_div a (1 / c) b).symm

private lemma one_mul' (a : M) : 1 * a = a := by
  simp

private lemma mul_one' (a : M) : a * 1 = a := by
  simp [DivGroup.div_self, DivGroup.div_one]

private lemma inv_mul_cancel' (a : M) : a⁻¹ * a = 1 := by
  simp [DivGroup.div_self]

private lemma div_eq_mul_inv' (a b : M) : a / b = a * b⁻¹ := by
  simp [one_div_one_div]

/-- Every `DivGroup` gives rise to a `Group`, with `a * b := a / (1 / b)` and `a⁻¹ := 1 / a`. -/
noncomputable def toGroup : Group M where
  mul := (· * ·)
  one := 1
  inv := (·⁻¹)
  div := (· / ·)
  mul_assoc := mul_assoc'
  one_mul := one_mul'
  mul_one := mul_one'
  inv_mul_cancel := inv_mul_cancel'
  div_eq_mul_inv := div_eq_mul_inv'

end DivGroup

/-! ### Reverse direction: Group → DivGroup -/

/-- Every `Group` gives rise to a `DivGroup`. -/
def Group.toDivGroup (M : Type*) [Group M] : DivGroup M where
  div_self a := div_self' a
  div_one a := div_one a
  div_div a b c := by
    simp [div_eq_mul_inv, mul_assoc]

/-! ### Commutative case -/

namespace CommDivGroup

variable {M : Type*} [CommDivGroup M]

/-- Every `CommDivGroup` gives rise to a `CommGroup`. -/
noncomputable def toCommGroup : CommGroup M where
  __ := DivGroup.toGroup (M := M)
  mul_comm a b := by
    simp only [DivGroup.mul_eq_div_inv]
    rw [CommDivGroup.div_comm a (1 / b), DivGroup.one_div_one_div]

end CommDivGroup

/-- Every `CommGroup` gives rise to a `CommDivGroup`. -/
def CommGroup.toCommDivGroup (M : Type*) [CommGroup M] : CommDivGroup M where
  __ := Group.toDivGroup M
  div_comm a b := by
    simp [div_eq_mul_inv, mul_comm]
