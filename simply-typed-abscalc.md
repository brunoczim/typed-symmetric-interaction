The syntax of terms is the same as in the original [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reduction rules are the same as in the original ac.
As in the original ac, variables can only be used once and are global.

# Syntax

```haskell
type ::=
  | A                            -- constant
  | type → type                  -- function
  | (type, type)                 -- pair

term ::=
  | x                            -- variable
  | λx. term                     -- abstraction (affine function)
  | (term term)                  -- application
  | (term, term)                 -- superposition (pair)
  | let (p, q) = term in term    -- definition (let)
  | ...                          -- additional terms associated with type constants
                                 --   (such as integer literals associated with `Int`)

proposition ::=
  | term : type                  -- annotation
  | proposition, proposition     -- conjunction, sequence
  | proposition ⊢ proposition    -- proved material implication, conclusion, entails

```

# Deduction/Typing Rules
```haskell
-- context
-- x must be a term
-- A must be a type
-- P must be a proposition
x : A ∈ P
──────────
P ⊢ x : A

-- abstraction
-- x must be a variable
-- t must be a term
-- A and B must be types
x : A ⊢ t : B
───────────────
(λx. t) : A → B

-- application
-- f and t must be terms
-- A and B must be types
f : A → B   t : A
─────────────────
(f t) : B

-- lambda projection
-- x and y must be variables
-- f and t must be terms
-- A, B and C must be types
f : A → B    x : A → B, y : A → B ⊢ t : C
──────────────────────────────────────────
(let (x, y) = f in t) : C

-- pair
-- t and u must be terms
-- A and B must be types
t : A   u : B
───────────────
(t, u) : (A, B)

-- pair projection
-- x and y must be variables
-- p and t must be terms
-- A, B and C must be types
p : (A, B)   x : A, y : B ⊢ t : C
───────────────────────────────────
(let (x, y) = m in t) : C

-- pair application
-- p and t must be terms
-- A, B and C must be types
p : (A → B, A → C)   t : A
───────────────────────────
p t : (B, C)

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
theorem (λx. x) : A → A
────────────────────────
1. | x : A              -- subproof hypothesis
2. x : A ⊢ x : A        -- subproof 1─1
3. (λx. x) : A → A      -- abstraction 2
```

## One function
```haskell
theorem (λf. λx. f x) : (A → A) → A → A
────────────────────────────────────────
1. | f : A → A                          -- subproof hypothesis
2. | | x : A                            -- subproof hypothesis
3. | | (f x) : A                        -- application 1, 2
4. | x : A ⊢ (f x) : A                  -- subproof 2─3
5. | (λx. f x) : A → A                  -- abstraction 4
6. f : A → A ⊢ (λx. f x) : A → A        -- subproof 1─5
7. (λf. λx. f x) : (A → A) → A → A      -- abstraction 6
```

## Two function
```haskell
theorem (λf. λx. let (g, h) = f in h (g x)) : (A → A) → A → A
──────────────────────────────────────────────────────────────
1.  | f : A → A                                                -- subproof hypothesis
2.  | | x : A                                                  -- subproof hypothesis
3.  | | | g : A → A, h : A → A                                 -- subproof hypothesis
4.  | | | g : A → A                                            -- simplification 3
5.  | | | h : A → A                                            -- simplification 3
6.  | | | (g x) : A                                            -- application 4, 2
7.  | | | (h (g x)) : A                                        -- application 6
8.  | | g : A → A, h : A → A ⊢ (h (g x)) : A                   -- subproof 3─7
9.  | | (let (g, h) = f in h (g x)) : A                        -- lambda projection 1, 8
10. | x : A ⊢ (let (g, h) = f in h (g x)) : A                  -- subproof 2─9
11. | (λx. let (g, h) = f in h (g x)) : A → A                  -- abstraction 10
12. f : A → A ⊢ (λx. let (g, h) = f in h (g x)) : A → A        -- subproof 1─11
13. (λf. λx. let (g, h) = f in h (g x)) : (A → A) → A → A      -- abstraction 12
```
