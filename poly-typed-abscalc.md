The syntax of terms is the same as in the original [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reduction rules are the same as in the original ac.
As in the original ac, variables can only be used once and are global.
The scope of quantified type variables, however, is not global,
and a new quantification with a previously quantified variable
always shadows the previous quantification.


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
-- T must be a type
-- U must be a type variable
x : T   U ∉ Constants
──────────────────────
x : ∀U. T

-- specialization
-- T and V must be types
-- U must be a type variable
∀U. T   ∀A ∈ quantified(T). ¬in(A, V)
──────────────────────────────────────
T{ U ↦ V }

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
1. | x : A                  -- subproof hypothesis
2. x : A ⊢ x : A           -- subproof 1─1
3. (λx. x) : A → A          -- abstraction 2
4. (λx. x) : ∀A. A → A      -- generalization 3
```

## Maybe Functor
```haskell
JUST := λx. λf. λg. f x : ∀A. ∀B. A → (A → B) → B → B
NOTHING := λy. λh. λi. i : ∀A. ∀B. A → (A → B) → B → B
```

```haskell
theorem (λx. λf. λg. f x) : ∀A. ∀B. A → (A → B) → B → B
────────────────────────────────────────────────────────
1.  | x : A                                              -- subproof hypothesis
2.  | | f : A → B                                        -- subproof hypothesis
3.  | | | g : B                                          -- subproof hypothesis
4.  | | | (f x) : B                                      -- application 2, 1
5.  | | g : B ⊢ (f x) : B                                -- subproof 3─4
6.  | | (λg. f x) : B → B                                -- abstraction 5
7.  | f : A → B ⊢ (λg. f x) : B → B                      -- subproof 2─6
8.  | (λf. λg. f x) : (A → B) → B → B                    -- abstraction 7
9.  x : A ⊢ (λf. λg. f x) : (A → B) → B → B              -- subproof 1─8
10. (λx. λf. λg. f x) : A → (A → B) → B → B              -- abstraction 9
11. (λx. λf. λg. f x) : ∀B. A → (A → B) → B → B          -- generalization 10
12. (λx. λf. λg. f x) : ∀A. ∀B. A → (A → B) → B → B      -- generalization 11
```
