The syntax of terms is the same as in the original [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reduction rules are the same as in the original ac.
As in the original ac, variables can only be used once and are global.
The scope of quantified type variables, however, is not global,
and a new quantification with a previously quantified variable
always shadows the previous quantification.

# Syntax
```haskell
type ::=
  | A                                        -- variable, constant
  | (type, type)                             -- pair
  | type → type                              -- function
  | Type[n]                                  -- The type of types from the universe n, where n is
  | ∀T. type                                 -- universal quantification over types
  | type type                                -- specialization
                                             --   a natural number (with zero first)
expression ::=
  | x                                        -- variable
  | λx. expression                           -- abstraction, lambda
  | expression expression                    -- application
  | (expression, expression)                 -- superposition, pair
  | let (p, q) = expression in expression    -- definition, let
  | ...                                      -- -- additional terms associated with type constants
                                             --      (such as integer literals associated with `Int`)

typable ::=
  | type                                     -- type
  | expression                               -- expression

proposition ::=
  | typable : type                           -- typing
  | proposition, proposition                 -- conjunction, sequence
  | proposition ⊢ proposition                -- proved material implication, conclusion, entails

```

# Predicates and Sets for Deduction Constraints

These properties are necessary only for verifying rules
and are derived by just observing the syntax of the propositions.

```haskell
in(proposition, proposition)                 -- is read "P is intensionally in Q"

quantified(type)                             -- quantified type variables of the type
    quantified(universal ∀A. B) = { A } ∪ quantified(B)
    quantified(_) = {}

Constants                                    -- the set of all type constants
```

# Deduction/Typing Rules

```haskell
-- type of types
─────────────────────────────
Type[n] : Type[n + 1]

-- function
-- A and B must be types
A : Type[n]   B : Type[n]
─────────────────────────
(A → B) : Type[n]

-- generalization
-- A', B' and B must be types
-- A must be a variable
-- t must be a typable
A' : Type[n + 1]   B' : Type[n + 1]   A : A' ⊢ B : B', x : B
─────────────────────────────────────────────────────────────
(∀A. B) : A' → B', t : (∀A. B)

-- specialization
-- A', A, B' and B must be types
-- t must be a typable
A' : Type[n + 1]   B' : Type[n + 1]   A : A' → B'   B : A'  t : A
──────────────────────────────────────────────────────────────────
(A B) : B'   t : A B

-- abstraction
-- x must be a variable
-- e must be an expression
-- A and B must be types
A : Type[0]   B : Type[0]   x : A ⊢ e : B
──────────────────────────────────────────
(λx. e) : A → B

-- application
-- A and B must be types
-- f and t must be typables
A : Type[n]   B : Type[n]   f : A → B   t : A
──────────────────────────────────────────────
(f t) : B

-- lambda projection
-- x and y must be variables
-- f and e must be expressions
-- A, B and C must be types
A : Type[0]   B : Type[0]   C : Type[0]   f : A → B    x : A → B, y : A → B ⊢ e : C
────────────────────────────────────────────────────────────────────────────────────
(let (x, y) = f in e) : C

-- pair
-- e and f must be typables
-- A and B must be types
A : Type[n]   B: Type[n]   e : A   f : B
─────────────────────────────────────────
(e, f) : (A, B)

-- pair projection
-- x and y must be variables
-- p and e must be expressions
-- A, B and C must be types
A : Type[0]   B : Type[0]   C : Type[0]   p : (A, B)   x : A, y : B ⊢ e : C
─────────────────────────────────────────────────────────────────────────────
(let (x, y) = m in e) : C

-- pair application
-- p and e must be expressions
-- A, B and C must be types
A : Type[0]   B : Type[0]   C : Type[0]   p : (A → B, A → C)   e : A
─────────────────────────────────────────────────────────────────────
p e : (B, C)

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

# Examples

## Id function

```haskell
theorem (λx. x) : ∀A. A → A
────────────────────────────
1.  | A : Type[0]                                        -- subproof hypothesis
2.  | | x : A                                            -- subproof hypothesis
3.  | x : A ⊢ x : A                                      -- subproof 2─2
4.  | (λx. x) : A → A                                    -- abstraction 3
5.  | A → A                                              -- function
6.  | A → A, (λx. x) : A → A                             -- conjunction 5, 4
7.  A : Type[0] ⊢ (λx. x) : A → A                        -- subproof 1─6
8.  Type[0] : Type[1]                                    -- type of types
9.  ∀A. A → A : Type[0] → Type[0], (λx. x) : ∀A. A → A   -- generalization 8, 8, 7
10. (λx. x) : ∀A. A → A                                  -- simplification 9
```
