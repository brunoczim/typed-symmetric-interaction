The syntax of terms is the same as in the original [symmetric interaction calculus](https://github.com/maiavictor/symmetric-interaction-calculus).
Reduction rules are the same as in the original sic.
As in the original sic, variables can only be used once and are global.

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
    x? : B,
    y? : C,
    p : A,
    t : T,
    Proj(A, B, C)
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

ξ | α, f : A, e : B, App(A, B, C)
───────────────────────────────── APP
ξ | α, (f t) : C

```

# Tips
Begin proving the inner-left most expression

# Examples

## Use before declare
Objective:
```haskell
(x, (λx. 3) "msg") : String ⨯ Nat
```

Proof:
```haskell
────────── +VAR
x? : String,
x : String
─────────── X,X
x : String,
x? : String
──────────────────────────────── CONST
x : String,
x? : String,
3 : Nat
──────────────────────────────────── LAM
x | x : String,
    (λx. 3) : String → Nat
─────────────────────────────────── CONST
x | x : String,
    (λx. 3) : String → Nat,
    "msg" : String,
─────────────────────────────────── ALI
x | x : String,
    (λx. 3) : String → Nat,
    "msg" : String,
    App(String → Nat, String, Nat)
─────────────────────────────────── APP
x | x : String,
    ((λx. 3) "msg") : Nat
────────────────────────────────────── PAIR
x | (x, (λx. 3) "msg") : String ⨯ Nat
────────────────────────────────────── FIN
⊢ (x, (λx. 3) "msg") : String ⨯ Nat
```

## Two Function
Objective:
```haskell
(λf. λx.
    let (f0, f1) = f in
    f0 (f1 x)) : (A ⨯ A → A ⨯ A) → A → A
```

Proof:
```haskell
────────────────────── +VAR
f? : (A ⨯ A → A ⨯ A),
f : (A ⨯ A → A ⨯ A)
────────────────────── +VAR
f? : (A ⨯ A → A ⨯ A),
f : (A ⨯ A → A ⨯ A),
x? : A,
x : A
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
x : A
────────────────────── +VAR
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
x : A,
f0? : A → A,
f0 : A → A
────────────────────── +VAR
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
x : A,
f0? : A → A,
f0 : A → A,
f1? : A → A,
f1 : A → A
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
x : A,
f0 : A → A,
f1? : A → A,
f1 : A → A
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f0 : A → A,
x : A,
f1? : A → A,
f1 : A → A
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f0 : A → A,
f1? : A → A,
x : A,
f1 : A → A
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f0 : A → A,
f1? : A → A,
f1 : A → A,
x : A
────────────────────── ALI
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f0 : A → A,
f1? : A → A,
f1 : A → A,
x : A,
App(A → A, A, A)
────────────────────── APP
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f0 : A → A,
f1? : A → A,
(f1 x) : A,
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f1? : A → A,
f0 : A → A,
(f1 x) : A
────────────────────── ALI
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f1? : A → A,
f0 : A → A,
(f1 x) : A,
App(A → A, A, A)
────────────────────── APP
f? : (A ⨯ A → A ⨯ A),
x? : A,
f : (A ⨯ A → A ⨯ A),
f0? : A → A,
f1? : A → A,
(f0 (f1 x)) : A
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f0? : A → A,
f : (A ⨯ A → A ⨯ A),
f1? : A → A,
(f0 (f1 x)) : A
────────────────────── X,X
f? : (A ⨯ A → A ⨯ A),
x? : A,
f0? : A → A,
f1? : A → A,
f : (A ⨯ A → A ⨯ A),
(f0 (f1 x)) : A
────────────────────── PPI
f? : (A ⨯ A → A ⨯ A),
x? : A,
f0? : A → A,
f1? : A → A,
f : (A ⨯ A → A ⨯ A),
(f0 (f1 x)) : A,
Proj(A ⨯ A, A, A)
─────────────────────────────────── PLI
f? : (A ⨯ A → A ⨯ A),
x? : A,
f0? : A → A,
f1? : A → A,
f : (A ⨯ A → A ⨯ A),
(f0 (f1 x)) : A,
Proj(A ⨯ A → A ⨯ A, A → A, A → A)
────────────────────────────────────────────── PROJ
f0, | f? : (A ⨯ A → A ⨯ A),
f1  | x? : A,
      (let (f0, f1) = f in f0 (f1 x)) : A,
────────────────────────────────────────────── LAM
f0, | f? : (A ⨯ A → A ⨯ A),
f1, | (λx. let (f0, f1) = f in
x   |     f0 (f1 x)) : A → A
────────────────────────────────────────────── LAM
f0, | (λf. λx.
f1, |      let (f0, f1) = f in
x   |      f0 (f1 x)) : (A ⨯ A → A ⨯ A),
f   |
───────────────────────────────────────────── FIN
⊢ (λf. λx.
      let (f0, f1) = f in
      f0 (f1 x)) : (A ⨯ A → A ⨯ A) → A → A
```
