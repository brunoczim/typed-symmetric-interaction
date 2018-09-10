The syntax of terms is the same as in the original [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reduction rules are the same as in the original ac.
As in the original ac, variables can only be used once and are global.

# Syntax
```haskell
type ::=
 | mono                                      -- simple type
 | poly                                      -- polymorphic type

mono ::=
  | A                                        -- variable, constant
  | mono mono                                -- specialization
  | mono → mono                              -- function
  | (mono, mono)                             -- pair

poly ::=
  | ∀T. type                                 -- universal quantification over types

expression ::=
  | x                                        -- variable
  | λx. expression                           -- abstraction, lambda
  | expression expression                    -- application
  | (expression, expression)                 -- superposition, pair
  | let (p, q) = expression in expression    -- definition, let
  | ...                                      -- -- additional terms associated with type constants
                                             --      (such as integer literals associated with `Int`)

proposition ::=
  | expression : type                        -- annotation
  | proposition, proposition                 -- conjunction, sequence
  | proposition ⊢ proposition                -- proved material implication, conclusion, entails

```

# Extra Syntax for Deduction

These properties are necessary only for verifying rules
and are derived by just observing the syntax of the propositions.

```
in(proposition, proposition)                 -- is read "P is intensionally in Q"

free(type)                                   -- free variables and constants of the type, where:
    free(variable A) = { A }
    free(specialization A B) = free(A) ∪ free(B)
    free(function A → B) = free(A) ∪ free(B)
    free(pair (A, B)) = free(A) ∪ free(B)
    free(universal ∀A. B) = free(B) - { A }

quantified(type)                             -- quantified type variables of the type
    quantified(universal ∀A. B) = { A } ∪ quantified(B)
    quantified(_) = {}

```

# Deduction/Typing Rules

```haskell
-- context
-- x must be an expression
-- A must be a type
-- P must be a proposition
in(x : A, P)
────────────
P ⊢ x : A

-- abstraction
-- x must be a variable
-- e must be an expression
-- A and B must be types
x : A ⊢ e : B
───────────────
(λx. t) : A → B

-- application
-- f and e must be expressions
-- A and B must be types
f : A → B   e : A
─────────────────
(f e) : B

-- lambda projection
-- x and y must be variables
-- f and e must be expressions
-- A, B and C must be types
f : A → B    x : A → B, y : A → B ⊢ e : C
──────────────────────────────────────────
(let (x, y) = f in e) : C

-- pair
-- e and f must be expressions
-- A and B must be types
e : A   f : B
───────────────
(e, f) : (A, B)

-- pair projection
-- x and y must be variables
-- p and e must be expressions
-- A, B and C must be types
p : (A, B)   x : A, y : B ⊢ e : C
───────────────────────────────────
(let (x, y) = m in e) : C

-- pair application
-- p and e must be expressions
-- A, B and C must be types
p : (A → B, A → C)   e : A
───────────────────────────────
p e : (B, C)

-- generalization
-- x must be an expression
-- T and U must be types
x : T   U ∉ free(T)
────────────────────
x : ∀U. T

-- specialization
-- T must be a type
-- U and V must be type variables
∀U. T   V ∉ quantified(U)
──────────────────────────
T{ U ↦V }

-- renaming
-- T must be a type
-- U and V must be type variables
∀U. T   V ∉ quantified(U)
──────────────────────────
∀V. T{ U ↦V }

-- modus ponens
-- P and Q must be propositions
P   P ⊢ Q
──────────
Q

-- simplification
-- P and Q must be propositions
P, Q
─────
P   Q

-- conjunction
-- P and Q must be propositions
P   Q
─────
P, Q

-- subproof, conclusion
-- P and Q must be propositions
P
───
...
───
Q
───────
P ⊢ Q
```
