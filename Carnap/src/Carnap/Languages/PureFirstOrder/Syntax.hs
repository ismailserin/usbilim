{-#LANGUAGE TypeSynonymInstances, UndecidableInstances, FlexibleInstances, MultiParamTypeClasses, GADTs, DataKinds, PolyKinds, TypeOperators, ViewPatterns, PatternSynonyms, RankNTypes, FlexibleContexts, AutoDeriveTypeable #-}
module Carnap.Languages.PureFirstOrder.Syntax 
where

import Carnap.Core.Data.AbstractSyntaxDataTypes
import Carnap.Core.Unification.Unification
import Carnap.Languages.Util.LanguageClasses
import Control.Lens (Plated)
import Control.Lens.Fold (anyOf)
import Control.Lens.Plated (cosmos, transform)
import Data.Typeable (Typeable)
import Carnap.Languages.Util.GenericConnectives

--------------------------------------------------------
--1. Data for Pure First Order Logic
--------------------------------------------------------

data PureMonadicPredicate a where
    MonPred :: Int -> PureMonadicPredicate Int

type PurePredicate = IntPred Bool Int

type PureConn = BooleanConn Bool

type PureSchematicPred = SchematicIntPred Bool Int

type PureConstant = IntConst Int

type PureVar = StandardVar Int

type PureQuant = StandardQuant Bool Int

--------------------------------------------------------
--2. Pure First Order Languages 
--------------------------------------------------------

type CoreLexicon =  Connective PureConn
                   :|: Quantifiers PureQuant
                   :|: SubstitutionalVariable
                   :|: Function PureConstant
                   :|: Function PureVar
                   :|: EndLang

type PureFirstOrderLanguageWith a = FixLang (a :|: CoreLexicon :|: EndLang)

pattern (:!!$:) :: (Typeable a, Typeable b) => PureFirstOrderLanguageWith c (a -> b) -> PureFirstOrderLanguageWith c a -> PureFirstOrderLanguageWith c b
pattern (:!!$:) f y    = f :!$: y
pattern PCon x arity   = FX (Lx2 (Lx1 (Connective x arity)))
pattern PQuant q       = FX (Lx2 (Lx2 (Bind q)))
pattern PSV n          = FX (Lx2 (Lx3 (SubVar n)))
pattern PConst c a     = FX (Lx2 (Lx4 (Function c a)))
pattern PVar c a       = FX (Lx2 (Lx5 (Function c a)))
pattern PAnd           = PCon And ATwo
pattern POr            = PCon Or ATwo
pattern PIf            = PCon If ATwo
pattern PIff           = PCon Iff ATwo
pattern PNot           = PCon Not AOne
pattern PBind q f      = PQuant q :!!$: LLam f
pattern (:&:) x y      = PAnd :!!$: x :!!$: y
pattern (:||:) x y     = POr  :!!$: x :!!$: y
pattern (:->:) x y     = PIf  :!!$: x :!!$: y
pattern (:<->:) x y    = PIff :!!$: x :!!$: y
pattern PNeg x         = PNot :!!$: x
pattern PUniv v f      = PBind (All v) f
pattern PExist v f     = PBind (Some v) f
pattern PC n           = PConst (Constant n) AZero
pattern PV s           = PVar (Var s) AZero

height :: PureFirstOrderLanguageWith a b -> Int
height (PUniv _ g)     = height (g $ PV "") + 1
height (PExist _ g)    = height (g $ PV "") + 1
height (phi :&: psi)   = max (height phi) (height psi)
height (phi :||: psi)  = max (height phi) (height psi)
height (phi :->: psi)  = max (height phi) (height psi)
height (phi :<->: psi) = max (height phi) (height psi)
height _               = 0


swap :: PureFirstOrderLanguageWith c b -> PureFirstOrderLanguageWith c b -> PureFirstOrderLanguageWith c a -> PureFirstOrderLanguageWith c a
swap a@(PV a') b@(PV b') x@(PV x') = if x' == a' then b else x
swap a b c = c

instance Schematizable (a (PureFirstOrderLanguageWith a)) => CopulaSchema (PureFirstOrderLanguageWith a) where
    appSchema (PQuant (All x)) (LLam f) e = schematize (All x) (show (f $ PV x) : e)
    appSchema (PQuant (Some x)) (LLam f) e = schematize (Some x) (show (f $ PV x) : e)
    appSchema x y e = schematize x (show y : e)

--TODO:This should be in a core.utils module
mapover :: (forall a . PureFirstOrderLanguage a -> PureFirstOrderLanguage a) -> PureFirstOrderLanguage a -> PureFirstOrderLanguage a
mapover f (x :!$: y) = mapover f x :!$: f y
mapover f x = x

--------------------------------------------------------
--2.1 Polyadic First Order Logic With Constant Symbols
--------------------------------------------------------

type PolyadicPredicates = Predicate PurePredicate 
                      :|: Predicate PureSchematicPred
                      :|: EndLang


type PureFirstOrderLexicon = PolyadicPredicates :|: CoreLexicon :|: EndLang

type PureFirstOrderLanguage = FixLang PureFirstOrderLexicon

type PureFOLForm = PureFirstOrderLanguage (Form Bool)

type PureFOLTerm = PureFirstOrderLanguage (Term Int)

pattern PPred x arity  = FX (Lx1 (Lx1 (Predicate x arity)))
pattern PSPred x arity = FX (Lx1 (Lx2 (Predicate x arity)))
pattern PP n a1 a2     = PPred (Pred a1 n) a2
pattern PS n           = PPred (Pred AZero n) AZero
pattern PPhi n a1 a2   = PSPred (SPred a1 n) a2

instance BooleanLanguage PureFOLForm where
        land = (:&:)
        lneg = PNeg
        lor  = (:||:)
        lif  = (:->:)
        liff = (:<->:)

instance IndexedPropLanguage PureFOLForm where
    pn = PS

instance PolyadicPredicateLanguage PureFirstOrderLanguage (Term Int) (Form Bool) where 
    ppn n a = PP n a a

instance IncrementablePredicate PureFirstOrderLexicon (Term Int) where
    incHead (PP n a b) = Just $ PP n (ASucc a) (ASucc a)
    incHead _  = Nothing

instance QuantLanguage PureFOLForm PureFOLTerm where
        lall  = PUniv 
        lsome  = PExist 

instance CanonicalForm PureFOLForm where
    canonical = relabelVars varStream
                where varStream = [i ++ j | i <- ["x"], j <- map show [1 ..]]

instance CanonicalForm PureFOLTerm

instance BoundVars PureFirstOrderLexicon where
    getBoundVar (PQuant (All v)) _ = PV v
    getBoundVar (PQuant (Some v)) _ = PV v
    getBoundVar _ _ = undefined

    getBindHeight (PQuant (All v)) (LLam f) = PV $ show $ height (f $ PV "" )
    getBindHeight (PQuant (Some v)) (LLam f) = PV $ show $ height (f $ PV "" )
    getBindHeight _ _ = undefined

    subBoundVar a b (phi :&: psi)   = subBoundVar a b phi :&: subBoundVar a b psi
    subBoundVar a b (phi :||: psi)  = subBoundVar a b phi :||: subBoundVar a b psi
    subBoundVar a b (phi :->: psi)  = subBoundVar a b phi :||: subBoundVar a b psi
    subBoundVar a b (phi :<->: psi) = subBoundVar a b phi :||: subBoundVar a b psi
    subBoundVar a@(PV w) b (PUniv v f) = PUniv v (\x -> subBoundVar sv x $ subBoundVar a b $ f sv)
        where sv = case getBindHeight (PQuant (All v)) (LLam f) of
                           c@(PV v') -> if w == v' then PV ('_':v') else c
    subBoundVar a@(PV w) b (PExist v f) = PUniv v (\x -> subBoundVar sv x $ subBoundVar a b $ f sv)
        where sv = case getBindHeight (PQuant (All v)) (LLam f) of
                       c@(PV v') -> if w == v' then PV ('_':v') else c
    subBoundVar a b phi = mapover (swap a b) phi 


instance LangTypes2 PureFirstOrderLexicon Term Int Form Bool

instance LangTypes2 PureFirstOrderLexicon Form Bool Term Int

instance RelabelVars PureFirstOrderLexicon Form Bool where
    subBinder (PUniv v f) y = Just $ PUniv y f 
    subBinder (PExist v f) y = Just $ PExist y f
    subBinder _ _ = Nothing

