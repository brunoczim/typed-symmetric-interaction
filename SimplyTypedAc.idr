module SimplyTypedAc

import Data.Vect

data Ty : Type where
  Fun   : Ty -> Ty -> Ty
  Prod  : Ty -> Ty -> Ty
  Const : Type -> Ty

data Sym : Type where
  Ident : String -> Ty -> Sym

data Term : Vect n Sym -> Ty -> Type where
  Var     : Elem (Ident _ a) xs -> Term xs a
  Lam     : Elem (Ident _ a) xs -> Term xs b -> Term xs (Fun a b)
  App     : Term xs (Fun a b) -> Term xs a -> Term xs b
  Pair    : Term xs a -> Term xs b -> Term xs (Prod a b)
  LetPair : Elem (Ident _ a) xs
    -> Elem (Ident _ b) xs
    -> Term xs (Prod a b)
    -> Term xs c
    -> Term xs c
  LetLam  : Elem (Ident _ (Fun a b)) xs
    -> Elem (Ident _ (Fun a b)) xs
    -> Term xs (Fun a b)
    -> Term xs c
    -> Term xs c
  Ext     : a -> Term xs (Const a)
