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

# Deduction/Typing Rules

```haskell
-- type of types
─────────────────────
Type[n] : Type[n + 1]

-- constant
-- A must be a type
-- a must be a constant typable
A : Type[n]
a is a constant of type A
──────────────────────────
a : A

-- function
-- A and B must be types
A : Type[n]   B : Type[n]
─────────────────────────
(A → B) : Type[n]

-- function decomposition
-- A and B must be types
(A → B) : Type[n]
──────────────────────────
A : Type[n]   B : Type[n]


-- generalization
-- A', B' and B must be types
-- A must be a variable
-- t must be a typable and is optional
A' : Type[n + 1]
B' : Type[n + 1]
A : A' ⊢ B : B', t : B
────────────────────────────────────────────
(∀A. B) : A' → B', t : ∀A. B

-- specialization
-- A', A, B' and B must be types
-- t must be a typable
A' : Type[n + 1]
B' : Type[n + 1]
A : A' → B'
B : A'
t : A
─────────────────────
(A B) : B'   t : A B

-- substitution
-- A', A and B must be types
-- T must be a type variable
-- t must be typable and is optional
-- if T is shadowed by a new quantification over T in A, substitution must stop
-- if B contains any quantified variable in A, the quantified variable must be renamed
A' : Type[n + 1]
((∀T. A) B) : A'
t : (∀T. A) B
────────────────────────────────────
(A{ T ↦ B }) : A'   t : A{ T ↦ B }

-- abstraction
-- x must be a variable
-- e must be an expression
-- A and B must be types
A : Type[0]
B : Type[0]
x : A ⊢ e : B
────────────────
(λx. e) : A → B

-- application
-- A and B must be types
-- f and t must be typables
A : Type[n]
B : Type[n]
f : A → B
t : A
─────────────────
(f t) : B

-- lambda projection
-- x and y must be variables
-- f and e must be expressions
-- A, B and C must be types
A : Type[0]
B : Type[0]
C : Type[0]
f : A → B
x : A → B, y : A → B ⊢ e : C
─────────────────────────────
(let (x, y) = f in e) : C

-- pair
-- e and f must be typables
-- A and B must be types
A : Type[n]
B : Type[n]
e : A
f : B
───────────────
(e, f) : (A, B)

-- pair decomposition
-- e and f must be typables
-- A and B must be types
A : Type[n]
B : Type[n]
(e, f) : (A, B)
───────────────
e : A   f : B

-- pair projection
-- x and y must be variables
-- p and e must be expressions
-- A, B and C must be types
A : Type[0]
B : Type[0]
C : Type[0]
p : (A, B)
x : A, y : B ⊢ e : C
─────────────────────────
(let (x, y) = m in e) : C

-- pair application
-- p and e must be expressions
-- A, B and C must be types
A : Type[0]
B : Type[0]
C : Type[0]
p : (A → B, A → C)
e : A
──────────────────
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
5.  | A → A : Type[0]                                    -- function 1, 1
6.  | A → A : Type[0], (λx. x) : A → A                   -- conjunction 5, 4
7.  A : Type[0] ⊢ A → A : Type[0], (λx. x) : A → A       -- subproof 1─6
8.  Type[0] : Type[1]                                    -- type of types
9.  ∀A. A → A : Type[0] → Type[0], (λx. x) : ∀A. A → A   -- generalization 8, 8, 7
10. (λx. x) : ∀A. A → A                                  -- simplification 9
```

## Maybe functor

### Just
```haskell
theorem (∀A. ∀B. A → (A → B) → B → B) : Type[0] → Type[0] → Type[0],
           (λx. λf. λg. f x) : ∀A. ∀B. A → (A → B) → B → B
────────────────────────────────────────────────────────────────────
1.  Type[0] : Type[1]                                                 -- type of types
2.  Type[0] → Type[0] : Type[1]                                       -- function 1, 1
3.  | A : Type[0]                                                     -- subproof hypothesis
4.  | | B : Type[0]                                                   -- subproof hypothesis
5.  | | (B → B) : Type[0]                                             -- function 4, 4
6.  | | (A → B) : Type[0]                                             -- function 3, 4
7.  | | ((A → B) → B → B) : Type[0]                                   -- function 6, 5
8.  | | (A → (A → B) → B → B) : Type[0]                               -- function 3, 7
9.  | | | x : A                                                       -- subproof hypothesis
10. | | | | f : A → B                                                 -- subproof hypothesis
11. | | | | | g : B                                                   -- subproof hypothesis
12. | | | | | (f x) : B                                               -- application 3, 4, 10, 9
13. | | | | g : B ⊢ (f x) : B                                         -- subproof 11─12
14. | | | | (λg. f x) : B → B                                         -- abstraction 4, 4, 13
15. | | | f : A → B ⊢ (λg. f x) : B → B                               -- subproof 10─14
16. | | | (λf. λg. f x) : (A → B) → B → B                             -- abstraction 6, 5, 15
17. | | x : A ⊢ (λf. λg. f x) : (A → B) → B → B                       -- subproof 9─16
18. | | (λx. λf. λg. f x) : A → (A → B) → B → B                       -- abstraction 3, 7, 17
19. | | (A → (A → B) → B → B) : Type[0],                              -- conjunction 8, 18
          (λx. λf. λg. f x) : A → (A → B) → B → B
20. | B : Type[0] ⊢ (A → (A → B) → B → B) : Type[0],                  -- subproof 4─19
        (λx. λf. λg. f x) : A → (A → B) → B → B
21. | (∀B. A → (A → B) → B → B) : Type[0] → Type[0],                  -- generalization 1, 1, 19
        (λx. λf. λg. f x) : ∀B. A → (A → B) → B → B
21. A : Type[0] ⊢ (∀B. A → (A → B) → B → B) : Type[0] → Type[0],      -- subproof 3─21
      (λx. λf. λg. f x) : ∀B. A → (A → B) → B → B
22. (∀A. ∀B. A → (A → B) → B → B) : Type[0] → Type[0] → Type[0],      -- generalization 1, 2, 21
      (λx. λf. λg. f x) : ∀A. ∀B. A → (A → B) → B → B
```

### Just 3
```haskell
theorem ∀B. (Nat → B) → B → B : Type[0] → Type[0],
          ((λx. λf. λg. g) 3) : ∀B. (Nat → B) → B → B
──────────────────────────────────────────────────────────────
1.  Type[0] : Type[1]                                             -- type of types
2.  Type[0] → Type[0] : Type[1]                                   -- function 1, 1
3.  Nat : Type[0]                                                 -- constant 1
4.  3 : Nat                                                       -- constant 3
5.  (∀A. ∀B. A → (A → B) → B → B) : Type[0] → Type[0] → Type[0],  -- Just
       (λx. λf. λg. f x) : ∀A. ∀B. A → (A → B) → B → B
6.  (∀A. ∀B. A → (A → B) → B → B) : Type[0] → Type[0] → Type[0]   -- simplification 5
7.  (λx. λf. λg. f x) : ∀A. ∀B. A → (A → B) → B → B               -- simplification 5
8.  ((∀A. ∀B. A → (A → B) → B → B) Nat) : Type[0] → Type[0]       -- application 1, 2, 6, 3
9.  (λx. λf. λg. f x) : (∀A. ∀B. A → (A → B) → B → B) Nat         -- specialization 1, 2, 6, 3, 7
10. (∀B. Nat → (Nat → B) → B → B) : Type[0] → Type[0]             -- substitution 2, 8
11. (λx. λf. λg. f x) : ∀B. Nat → (Nat → B) → B → B               -- substitution 2, 8, 9
12. | B : Type[0]                                                 -- subproof hypothesis
13. | ((∀B. Nat → (Nat → B) → B → B) B) : Type[0]                 -- application 1, 1, 10, 12
14. | (λx. λf. λg. f x) : (∀B. Nat → (Nat → B) → B → B) B         -- specialization 1, 1, 10, 12, 11
15. | (Nat → (Nat → B) → B → B) : Type[0]                         -- substitution 1, 13
16. | (λx. λf. λg. f x) : Nat → (Nat → B) → B → B                 -- substitution 1, 13, 14
17. | ((Nat → B) → B → B) : Type[0]                               -- function decomposition 15
18. | ((λx. λf. λg. f x) 3) : (Nat → B) → B → B                   -- application 3, 17, 16, 4
19. | (Nat → (Nat → B) → B → B) : Type[0],                        -- conjunction 17, 18
        ((λx. λf. λg. f x) 3) : (Nat → B) → B → B
20. B : Type[0] ⊢(Nat → (Nat → B) → B → B) : Type[0],             -- subproof 12─19
      ((λx. λf. λg. f x) 3) : (Nat → B) → B → B
21. ∀B. (Nat → B) → B → B : Type[0] → Type[0],                    -- generalization 1, 1, 20
      ((λx. λf. λg. g) 3) : ∀B. (Nat → B) → B → B
```
