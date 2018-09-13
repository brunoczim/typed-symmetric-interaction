The syntax of terms is the same as in the original [abstract calculus](https://github.com/MaiaVictor/abstract-calculus).
Reduction rules are the same as in the original ac.
As in the original ac, variables can only be used once and are global.

# Syntax

```haskell
type ::=
    | A                                        -- constant
    | type → type                              -- function
    | type ⨯ type                              -- pair

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
    | P(x, y, z, ...)                          -- predicate

declared list ::=
    | ∅                                        -- empty (can be omitted)
    | x, declared list                         -- variable

formula ::=
    | declared list \| binding list            -- proof in progress
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
-- exchange

ξ | α, P, Q, β
─────────────── X,X
ξ | α, Q, P, β


-- finalization

ξ | e : A
────────── FIN
⊢ e : A


-- constant

ξ | α   c is a constant of type A
────────────────────────────────── CONST
ξ | α, c : A


-- variable introduction

ξ | α   x ∉ ξ   ∀T. (x : T) ∉ α   ∀T. (x? : T) ∉ α
─────────────────────────────────────────────────── +VAR
ξ | α, x? : A, x : A


-- variable elimination

ξ | α, x? : A, x : A
───────────────────── -VAR
ξ | α


-- use elimination

ξ | α, x : A
───────────── -USE
ξ | α


-- abstraction/lambda

ξ | α, x? : A, t : B
────────────────────────── LAM
ξ, x | α, (λx. t) : A → B


-- pair/product/tuple

ξ | α, t : A, u : B
────────────────────── PAIR
ξ | α, (t, u) : A ⨯ B


-- projectable pair instance

ξ | α,
────────────────────────  PPI
ξ | α, Proj(A ⨯ B, A, B)


-- projectable lambda instance

ξ | α, Proj(C, D, E)
────────────────────────────────────  PLI
ξ | α, Proj(A ⨯ B → C, A → D, B → E)


-- projection

ξ | α,
    Proj(A, B, C),
    x? : B,
    y? : C,
    p : A,
    t : T
─────────────────────────────────────── PROJ
ξ, x, y | α, (let (x, y) = p in t) : T


-- applicable lambda instance

ξ | α
──────────────────────── ALI
ξ | α, App(A → B, A, B)


-- applicable pair instance

ξ | α, App(A, C, D), App(B, C, E)
───────────────────────────────── API
ξ | α, App(A ⨯ B, C, D ⨯ E)


-- application

ξ | α, App(A, B, C), f : A, e : B
───────────────────────────────── APP
ξ | α, (f t) : C

```

# Tips
Begin proving the inner-left most expression

# Examples

## Use before declare
Objective: `(x, (λx. 3) "msg") : (String, Nat)`

```haskell
────────── +VAR
x? : String,
x : String
─────────── X,X
x : String,
x? : String
─────────── ALI
x : String,
x? : String,
App(String → Nat, String, Nat)
─────────────────────────────── X, X
x : String,
App(String → Nat, String, Nat),
x? : String
──────────────────────────────── CONST
x : String,
App(String → Nat, String, Nat),
x? : String,
3 : Nat
──────────────────────────────────── LAM
x | x : String,
    App(String → Nat, String, Nat),
    (λx. 3) : String → Nat
─────────────────────────────────── CONST
x | x : String,
    App(String → Nat, String, Nat),
    (λx. 3) : String → Nat,
    "msg" : String
─────────────────────────────────── APP
x | x : String,
    ((λx. 3) "msg") : Nat
────────────────────────────────────── PAIR
x | (x, (λx. 3) "msg") : (String, Nat)
────────────────────────────────────── FIN
⊢ (x, (λx. 3) "msg") : (String, Nat)
```
