# Summary of changes for run 334e6383-4682-4ac3-9ba2-85428afedfee
## Subtraction-Based Group Axiomatization — Formalized in Lean 4

I formalized the equivalence between the standard group axioms on `(M, 0, +)` and a subtraction-based axiomatization on `(M, 0, -)`.

### The Three Axioms

The `SubtractionGroup` structure (in `RequestProject/SubtractionGroup.lean`) uses just **three axioms**, each with at most 3 variables:

1. **`a - a = 0`** — Self-subtraction yields the identity *(1 variable)*
2. **`0 - (0 - a) = a`** — Double negation cancels *(1 variable)*
3. **`(a - b) - (c - b) = a - c`** — Right-translation invariance *(3 variables)*

Addition is then *defined* as: **`a + b := a - (0 - b)`**

### What Was Proved (all machine-verified, no sorry)

**Forward direction** (`SubtractionGroup → Group`):
From just the three axioms above, I derived:
- `a - 0 = a` and `-(a - b) = b - a` (derived properties)
- Left/right identity: `0 + a = a` and `a + 0 = a`
- Left/right inverse: `(-a) + a = 0` and `a + (-a) = 0`
- **Associativity**: `(a + b) + c = a + (b + c)` — the hardest derivation, using a clever double application of Axiom 3

This yields a `Group` instance from any `SubtractionGroup`.

**Reverse direction** (`Group → SubtractionGroup`):
Every group satisfies the three axioms when defining `a - b := a * b⁻¹`.

**Round-trip properties**:
- The recovered addition equals the original multiplication: `a + b = a * b`
- The recovered identity equals the original identity: `e = 1`
- The recovered negation equals the original inverse: `-a = a⁻¹`

### On Dropping Axiom 2

As you intuited, Axiom 2 (`0 - (0 - a) = a`, double negation) is the one that gives invertibility. Without it:
- You can still define `a - (0 - b)`, but you can't prove `0 - (0 - b) = b`, so this "addition" doesn't recover `b` from its negation.
- The structure `(M, 0, -)` with only Axioms 1 and 3 is weaker — it corresponds roughly to a monoid where you have subtraction but not necessarily inverses. This is indeed a distinct (and largely unnamed) algebraic structure.

### Intuition for the Axioms

- **Axiom 1** says "an element minus itself is zero" — the most basic property of subtraction.
- **Axiom 2** says "negation is involutive" — negating twice gets you back. This is what makes inversion work.
- **Axiom 3** says "subtraction is invariant under right translation" — if you subtract the same thing from both operands, the result doesn't change. This is the associativity-like axiom. In a group: `(a·b⁻¹)·(c·b⁻¹)⁻¹ = a·b⁻¹·b·c⁻¹ = a·c⁻¹`.