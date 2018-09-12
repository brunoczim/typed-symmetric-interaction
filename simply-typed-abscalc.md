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

One of the key features of this type system is:
Variables have a left assignment value (lval) and a right assingment value (rval) version.
Also, both lval and rval can only be used once. If you have both lval and rval available,
they can be discarded. But if one of them is missing, only rval can be discarded.

The lambda argument and the variables defined in let correspond to lval, while the variable
as an expression correspond to rval. Once a lval is defined, it is put into a declared variable
list, and cannot be introduced once again.

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
α, x? : A, x : A | ξ

α, x? : A, x : A | ξ
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
α, (let (x, y) = t in u) : C | x, y, ξ

α, x? : A, y? : B, t : (A, B), u : C | ξ
──────────────────────────────────────── pair projection
α, (let (x, y) = t in u) : C | x, y, ξ

α, f : A → B, t : A | ξ
─────────────────────── application
α, (f t) : B | ξ

α, f : (A → B, A → C), t : A | ξ
──────────────────────────────── pair application
α, (f t) : (B, C) | ξ

```

# Tips
Begin proving the inner-left most expression

# Examples

## Use before declare
Objective: `(x, (λx. 3) "msg") : (String, Nat)`

```haskell
────────── variable introduction
x? : String,
x : String
───────── exchange
x : String,
x? : String
───────── constant
x : String,
x? : String,
3 : Nat
────────────────────── abstraction
x : String,
(λx. 3) : String → Nat
| x
────────────────────── constant
x : String,
(λx. 3) : String → Nat,
"msg" : String
| x
────────────────────── application
x : String,
((λx. 3) "msg") : Nat
| x
─────────────────────────────────── pair
(x, (λx. 3) "msg") : (String, Nat),
| x
──────────────────────────────────── finalization
⊢ (x, (λx. 3) "msg") : (String, Nat)
```
