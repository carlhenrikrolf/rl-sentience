# Summary of changes for run 718e5e35-1c4a-46cf-832a-54ea3b30d404
## Division-First Axiomatization of Groups — Fully Formalized in Lean 4

I've created a complete, machine-verified formalization in `RequestProject/Basic.lean` that axiomatizes groups starting from division (or subtraction) rather than multiplication.

### The Axiom System

**Non-abelian (Group) axioms — `DivGroup`** (4 axioms):
1. `a / a = 1` — self-division (1 variable)
2. `(a / c) / (b / c) = a / b` — right cancellation (3 variables)
3. `(a / b) / c = a / (c / (1 / b))` — division-associativity (3 variables)
4. `1 / (1 / a) = a` — **invertibility** (1 variable) ← the separable axiom

**Abelian (CommGroup) axioms — `DivAbGroup`** (5 axioms = strict superset):
- All 4 above, plus:
5. `a / (1 / b) = b / (1 / a)` — commutativity (2 variables)

### The Invertibility Axiom

Axiom 4 (`inv_involution`: `1 / (1 / a) = a`) is the minimal, separable axiom that enables recovering multiplication. It says the "inversion" map `a ↦ 1/a` is an involution (like double negation `−(−a) = a`).

**With it**, we define `a * b := a / (1 / b)` and prove this gives a full Group (or CommGroup with axiom 5).

**Without it**, the remaining 3 axioms define a weaker structure called `DivStructure` where:
- Right cancellation holds
- The map `φ(a) = 1/a` reverses division order: `1/(a/b) = b/a`
- Elements in the image of `/` have a right identity: `(a/b)/1 = a/b`
- But `a/1 = a` cannot be proved for all `a`, so multiplication with a two-sided identity cannot be defined

### What's Proved

All proofs are machine-verified (no `sorry`, no non-standard axioms):

| Theorem | Statement |
|---------|-----------|
| `DivGroup.toGroup` | Every `DivGroup` gives a `Group` |
| `DivAbGroup.toCommGroup` | Every `DivAbGroup` gives a `CommGroup` |
| `Group.toDivGroup` | Every `Group` gives a `DivGroup` |
| `CommGroup.toDivAbGroup` | Every `CommGroup` gives a `DivAbGroup` |
| `group_divGroup_mul_eq` | The round-trip multiplication matches: `a / (1/b) = a * b` |
| `group_divGroup_inv_eq` | The round-trip inverse matches: `1/a = a⁻¹` |

### Interpretation Table

| Division axiom | Additive reading (`−`, `0`) | Multiplicative reading |
|---|---|---|
| `a / a = 1` | `a − a = 0` | self-division |
| `(a/c)/(b/c) = a/b` | `(a−c)−(b−c) = a−b` | right cancellation |
| `(a/b)/c = a/(c/(1/b))` | `(a−b)−c = a−(c+b)` | associativity |
| `1/(1/a) = a` | `−(−a) = a` | double inversion |
| `a/(1/b) = b/(1/a)` | `a+b = b+a` | commutativity |