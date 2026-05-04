# Summary of changes for run b60ccdbc-7dd8-4604-a912-d31a94252be4
## Subtraction Groups: Axiomatizing Abelian Groups via Subtraction

I formalized and proved in Lean 4 the equivalence between abelian groups and "subtraction groups." The formalization is in `RequestProject/SubtractionGroup.lean`.

### The Three Axioms for (M, 0, ⊖)

An abelian group can be axiomatized with just three simple axioms on a "subtraction" operation:

1. **`a ⊖ 0 = a`** — subtracting zero does nothing (1 variable)
2. **`a ⊖ a = 0`** — self-subtraction yields zero (1 variable)
3. **`a ⊖ (b ⊖ c) = c ⊖ (b ⊖ a)`** — the "swap" axiom (3 variables)

Each axiom uses at most 3 variables, as requested.

### Derived Operations

- **Negation:** `-a := 0 ⊖ a`
- **Addition:** `a + b := a ⊖ (0 ⊖ b)`

### What determines commutativity?

**Axiom 3 is the commutativity axiom.** Setting `b = 0` in axiom 3 immediately gives `a + c = c + a`. 

For a **non-commutative** (non-abelian) group, you would replace axiom 3 with the weaker axiom:
```
a ⊖ (b ⊖ c) = (a ⊖ (0 ⊖ c)) ⊖ b
```
This gives associativity of the derived addition but **not** commutativity. Axiom 3 is strictly stronger and implies both.

### The monoid case

If you drop the requirement that every element has an inverse (i.e., subtraction is not total), the `+` side gives a commutative monoid, and the `⊖` side gives a structure related to **BCK-algebras** or **effect algebras** in the literature. However, the three axioms as stated already force the existence of inverses — axioms 2 and 3 together guarantee a full group structure.

### What was formally proved

The Lean file proves:
- All fundamental derived identities (`neg_neg`, `neg_sub`, etc.)
- The four abelian group axioms for the derived addition (commutativity, associativity, identity, inverse)
- **`SubGrp → AddCommGroup`**: every subtraction group gives an abelian group
- **`AddCommGroup → SubGrp`**: every abelian group satisfies the subtraction axioms

All proofs compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).