The syntax of terms is the same as in the original [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reduction rules are the same as in the original ac.
As in the original ac, variables can only be used once and are global.

# Syntax

```haskell
type ::=
    | A                                        -- constant
    | type → type                              -- function
    | (type, type)                             -- pair

expression ::=
    | x                                        -- variable
    | λx. expression                           -- abstraction, lambda
    | expression expression                    -- application
    | (expression, expression)                 -- superposition, pair
    | let (p, q) = expression in expression    -- definition, let
    | ...                                      -- -- additional terms associated with type constants
                                               --      (such as integer literals associated with `Int`)

binding list ::=
    | ∅                                        -- empty (can be omitted)
    | expression : type, binding list          -- typing
    | x? : type, binding list                  -- declarable variable

declared list ::=
    | ∅                                        -- empty (can be omitted)
    | x, declared list                         -- variable

formula ::=
    | binding list \| declared list            -- in progress
    | ⊢ expression : type                      -- proved
```

# Inference Rules
```haskell
α, P, Q, β | ξ
─────────────── exchange
α, Q, P, β | ξ

e : A | ξ
────────── finalization
⊢ e : A

α, c is a constant of type A | ξ
──────────────────────────────── constant
α, c : A | ξ

α | ξ    ∀T. (x : T) ∉ α   ∀T. (x? : T) ∉ α   x ∉ ξ
──────────────────────────────────────────────────── variable introduction
α, x : A, x? : A | ξ

α, x : A, x? : A | ξ
───────────────────── variable elimination
α | ξ

α, x : A | ξ
──────────── use elimination
α | ξ

α, x? : A, t : B | ξ
───────────────────────── abstraction
α, (λx. t) : A → B | x, ξ

α, t : A, u : B | ξ
────────────────────── pair
α, (t, u) : (A, B) | ξ

α, x? : A → B, y? : B → B, t : A → B, u : C | ξ
─────────────────────────────────────────────── lambda projection
α, (let (x, y) = t in u) : C | ξ

α, x? : A, y? : B, t : (A, B), u : C | ξ
──────────────────────────────────────── pair projection
α, (let (x, y) = t in u) : C | ξ

α, f : A → B, t : A | ξ
─────────────────────── application
α, (f t) : B | ξ

α, f : (A → B, A → C), t : A | ξ
──────────────────────────────── pair application
α, (f t) : (B, C) | ξ

```
