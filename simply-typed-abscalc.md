The syntax of terms is the same as in the original [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reduction rules are the same as in the original ac.
As in the original ac, variables can only be used once and are global.

# Syntax

```haskell
type ::=
  | a                            -- constant
  | type → type                  -- function
  | (type, type)                 -- pair

term ::=
  | x                            -- variable
  | λx. term                     -- abstraction (affine function)
  | (term term)                  -- application
  | (term, term)                 -- superposition (pair)
  | let (p, q) = term in term    -- definition (let)
  | ...                          -- additional terms associated with type constants
                                 -- (such as integer literals associated with `int`)

proposition ::=
  | term : type                  -- annotation
  | proposition, proposition     -- sequence
  | proposition ⊢ proposition    -- conclusion

```

# Typing Rules
```haskell
-- context
-- x must be a term
-- a must be a type
-- s must be a proposition
x : a ∈ s
───────────
s ⊢ x : a

-- abstraction
-- x must be a variable
-- t must be a term
-- a and b must be types
x : a ⊢ t : b
────────────────
(λx. t) : a → b

-- application
-- t and u must be terms
-- a and b must be types
t : a → b, u : a
──────────────────────
(t u) : b

-- pair
-- t and u must be terms
-- a and b must be types
t : a, u : b
──────────────────────
(t, u) : (a, b)

-- pair projection
-- x and y must be variables
-- p and t must be terms
-- a and b must be types
x : a, y : b, p : (a, b) ⊢ t : c
─────────────────────────────────
(let (x, y) = p in t) : c

-- lambda projection
-- x and y must be variables
-- f and t must be terms
-- a and b must be types
x : a → b, y : a → b, f : a → b ⊢ t : c
───────────────────────────────────────
(let (x, y) = f in t) : c

-- pair application
-- p and t must be terms
-- a, b, c must be types
p : (a → b, a → c), t : a
─────────────────────────
p t : (b, c)

-- conclusion
-- r and s must be propositions
-- this is not exactly a rule, it may be implicit, but I wanted to show it.
r
─
s
──────
r ⊢ s
```

# Examples

## Id function
```haskell
theorem (λx. x) : a → a
───────────────────────
1. | x : a              -- subproof hipothesis
2. | x : a              -- context 1
3. x : a ⊢ x : a       -- subproof 1─2
4. (λx. x) : a → a      -- abstraction 3
```

## One function
```haskell
theorem (λf. λx. f x) : (a → a) → a → a
───────────────────────────────────────
1. | f : a → a                          -- subproof hipothesis
2. | | x : a                            -- subproof hipothesis
3. | | (f x) : a → a                    -- application 1, 2
4. | x : a ⊢ (f x) : a → a              -- subproof 2─3
5. | (λx. f x) : a → a                  -- abstraction 4
6. f : a → a ⊢ (λx. f x) : a → a        -- subproof 1─5
7. (λf. λx. f x) : (a → a) → a → a      -- abstraction 6
```
