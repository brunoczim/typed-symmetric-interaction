The syntax of terms is the same as in [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reductionn rules are the same as in [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).

# Syntax

```idris
type ::=
  | type → type                  -- function
  | (type, type)                 -- pair
  | a                            -- constant

term ::=
  | λx. term                     -- abstraction (affine function)
  | (term term)                  -- application
  | (term,term)                  -- superposition (pair)
  | let (p, q) = term in term    -- definition (let)
  | x                            -- variable

proposition ::=
  | term : type                  -- annotation
  | proposition, proposition     -- sequence
  | proposition ⊢ proposition    -- conclusion

```

# Typing Rules
```haskell
-- abstraction
-- x must be a variable
-- t must be a term
-- a and b must be types
x : a ⊢ t : b
────────────────
(λx. t) : a → b

-- application
-- x must be a variable
-- t and u must be terms
-- a and b must be types
(λx. t) : a → b, u : a
──────────────────────
((λx. t) u) : b

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
r
─
s
──────
r ⊢ s
```
