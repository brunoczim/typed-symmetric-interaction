module SimplyTypedAc

data Ty : Type where
  Fun   : Ty -> Ty -> Ty
  Pair  : Ty -> Ty -> Ty
  Const : Type -> Ty

data Sym : Ty -> Type where
  Ident : String -> (a : Ty) -> Sym a

data Term : Ty -> Type where
  Lam  : Sym a -> Term b -> Term (Fun a b)
  App  : Term (Fun a b) -> Term a -> Term b
  Pair : Term a -> Term b -> Term (Pair a b)
  LetP : Sym a -> Sym b -> Term (Pair a b) -> Term c -> Term c
  LetF : Sym (Fun a b) -> Sym (Fun a b) -> Term (Fun a b) -> Term c -> Term c
  Var  : Sym a -> Term a
  Ext  : a -> Term (Const a)
