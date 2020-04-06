import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)
import qualified Data.Map.Strict as Map
import Data.Maybe()
data Exp = 
    -- unary operator: Op name expression
    Op1 String Exp
    -- binary operator: Op name leftExpression rightExpression
    | Op2 String Exp Exp
    -- real value: e.g. Real 1.0
    | Real Float

    | Integer Int
    -- variable: e.g. Var "x"
    | Var String
    deriving(Show,Eq)
-- Data-structure for boolean expressions
data BoolExp = 
    -- binary operator on boolean expressions
    OpB String BoolExp BoolExp
    -- negation, the only unary operator
    | Not BoolExp
    -- comparison operator: Comp name expression expression
    | Comp String Exp Exp
    -- true and false constants
    |True_C
    |False_C

    |V String
    deriving(Show,Eq)

data Value = R Float | B Bool deriving (Show,Eq)

data GenExp = FloatExp Exp | BExp BoolExp deriving(Show,Eq)
-- Data-structure for statements
data Statement = 
    -- Variable assignment
    Assign String GenExp
    -- If statement
    | If BoolExp [Statement] [Statement]
    | While BoolExp [Statement]
    |For String Exp Exp [Statement]
    |Write GenExp
    |WriteS String
    |Read
    |ProcCall String
    -- Block
    | Block [Statement]
    deriving(Show,Eq)

data VType = REAL | BOOL 

data Definition =
    Dtype String VType
    |Dval String GenExp
    |Proc String [Statement]
    |Func String [Statement] VType

addVal:: [Map.Map String Value]-> String->Value -> [Map.Map String Value]
addVal (t:scope) str val = Map.insert str val t : scope

getVal::[Map.Map String Value]->String-> Value
getVal (t:scope) str = case Map.lookup str t of
        Just a -> a
        Nothing -> error "Id not in scope"

--for functions
addScopeEmpty:: [Map.Map String Value] -> [Map.Map String Value]
addScopeEmpty scope = (Map.empty:scope) 

--for everything else
addScope::[Map.Map String Value] -> [Map.Map String Value]
--taken from forth code for duplicating value on list
addScope (x:scope) = x:x:scope 

deleteScope:: [Map.Map String Value] -> [Map.Map String Value]
-- union put all values that are in x in y if the keys are the same use the value that is in x
-- intersection y only take values that are in y
deleteScope (x:y:scope) = (Map.intersection x y):scope
deleteScope [x] = [x]
deleteScope [] = []

deleteScopeFuncs:: [Map.Map String Value] -> [Map.Map String Value]
deleteScopeFuncs (x:scope) = scope;

toFloat :: Value->Float
toFloat (R x) = x
toFloat _ = error "not Float"


toBool :: Value->Bool
toBool (B x) = x
toBool _ = error "not Bool"

type Program = ([Definition],[Statement])

intExp :: Exp ->[Map.Map String Value] -> Value
intExp (Real e1) _ =(R e1)
intExp (Var e1) s =(getVal s e1)
intExp (Op1 "ln" e1) s = (R (log (toFloat(intExp e1 s))))
intExp (Op1 "sin" e1) s = (R (sin (toFloat(intExp e1 s))))
intExp (Op1 "cos" e1) s = (R (cos (toFloat(intExp e1 s))))
intExp (Op1 "sqr" e1) s = (R (sqrt (toFloat(intExp e1 s))))
intExp (Op2 "exp" e1 e2) s = (R $ toFloat(intExp e1 s) ** toFloat(intExp e2 s))
intExp (Op2 "+" e1 e2) s = (R $ toFloat(intExp e1 s) + toFloat(intExp e2 s))
intExp (Op2 "*" e1 e2) s = (R $ toFloat(intExp e1 s) * toFloat(intExp e2 s))
intExp (Op2 "/" e1 e2) s = (R $ toFloat(intExp e1 s) / toFloat(intExp e2 s))
intExp (Op2 "-" e1 e2) s = (R $ toFloat(intExp e1 s) - toFloat(intExp e2 s))
intExp _ _ =error "Invalid Operation"

boolExp:: BoolExp->[Map.Map String Value]-> Value
boolExp (True_C) _ = (B True)
boolExp (False_C) _ = (B False)
boolExp (Not e1) s = (B (not(toBool(boolExp e1 s))))
boolExp (V e1) s = (getVal s e1)
boolExp ( OpB "and" e1 e2) s = (B $ toBool(boolExp e1 s) && toBool(boolExp e2 s))
boolExp ( OpB "or" e1 e2) s = (B $ toBool(boolExp e1 s) || toBool(boolExp e2 s))
boolExp (Comp ">" e1 e2) s = (B (toFloat(intExp e1 s) > toFloat(intExp e2 s)))
boolExp (Comp "<" e1 e2) s = (B (toFloat(intExp e1 s) < toFloat(intExp e2 s)))
boolExp (Comp ">=" e1 e2) s = (B (toFloat(intExp e1 s) >= toFloat(intExp e2 s)))
boolExp (Comp "<=" e1 e2) s = (B (toFloat(intExp e1 s) <= toFloat(intExp e2 s)))
boolExp (Comp "=" e1 e2) s = (B (toFloat(intExp e1 s) == toFloat(intExp e2 s)))
boolExp (Comp "<>" e1 e2) s = (B (toFloat(intExp e1 s) /= toFloat(intExp e2 s)))
boolExp _ _ = error "Invalid Operation"

evalIf:: Statement->String->[Map.Map String Value]->  Map.Map String [Statement] -> (String,[Map.Map String Value],Map.Map String [Statement])
evalIf (If b e1 e2) out s funcT = do 
    if toBool(boolExp b s) 
        then evalStatements e1 out (deleteScope s) funcT  
        else evalStatements e2 out (deleteScope s) funcT

evalWhile:: Statement->String->[Map.Map String Value]-> Map.Map String [Statement] -> (String,[Map.Map String Value],Map.Map String [Statement])
evalWhile (While b e1) out s funcT = do
    if toBool(boolExp b s)
        then let (newOut,newMap, newFunc)  = evalStatements e1 out s funcT
                    in evalWhile (While b e1) newOut newMap funcT
        else (out,(deleteScope s),funcT)


evalFor:: Statement->String->[Map.Map String Value]-> Map.Map String [Statement] -> (String,[Map.Map String Value],Map.Map String [Statement])
evalFor (For name count max body) out s funcT = if (toFloat(getVal s name)) < (toFloat(intExp max s))
                                            then let (newOut,newMap,newFunc) = evalStatements body out s funcT
                                                        in evalFor (For name count max body) newOut (addVal newMap name (R (toFloat(getVal newMap name) + 1.0))) funcT
                                            else (out,(deleteScope s),funcT)

evalProc:: Statement -> String -> [Map.Map String Value]-> Map.Map String [Statement] -> (String,[Map.Map String Value],Map.Map String [Statement])
evalProc (ProcCall name) out table funcT = case Map.lookup name funcT of
                                    Just a ->  evalStatements a out (addScopeEmpty table) funcT
                                    Nothing -> error "function does not exist"
    
eval2 :: GenExp -> [Map.Map String Value] -> Value
--evalout for statements that add to string
eval2 (FloatExp e1) s = intExp e1 s
eval2 (BExp e1) s = boolExp e1 s

eval :: Statement-> String -> [Map.Map String Value]-> Map.Map String [Statement] -> (String,[Map.Map String Value],Map.Map String [Statement])
eval (Assign name e1) out s funcT = (out, addVal s name (eval2 e1 s),funcT)
eval (Block prog) out s funcT = evalStatements prog out s funcT
eval (If b e1 e2) out s funcT = evalIf (If b e1 e2) out (addScope s) funcT
eval (While b e1) out s funcT = evalWhile (While b e1) out (addScope s) funcT
eval (For name count max body) out s funcT =  let newScope = (addScope s)
                                            in evalFor (For name count max body) out ((addVal newScope name (intExp count s))) funcT
eval Read out s funcT = (out,s,funcT)
eval (Write e1) out s funcT = (out ++ show(eval2 e1 s) ++ "\n",s,funcT)
eval (WriteS e1) out s funcT = (out ++ e1 ++ "\n", s, funcT)
eval (ProcCall name) out table funcT = let (newOut, newTable, newFunc) = evalProc (ProcCall name) out table funcT
                                        in (newOut, (deleteScopeFuncs newTable) , newFunc)
eval _ _ _ _ = error "not valid statement"


evalStatements:: [Statement] -> String -> [Map.Map String Value] -> Map.Map String [Statement]-> (String,[Map.Map String Value],Map.Map String [Statement])
evalStatements (x:xs) out scope funcT = let (output,scopes,fun) = eval x out scope funcT
                                    in evalStatements xs output scopes fun
evalStatements [] out scope funcT = (out, scope,funcT)

def::Definition ->  [Map.Map String Value] -> Map.Map String [Statement] ->  ( [Map.Map String Value],  Map.Map String [Statement] )
def (Dtype name x) table funcT = case x of
                    REAL -> (addVal table name (R 0.0), funcT)
                    BOOL -> (addVal table name (B True),funcT)
def (Dval name x) table funcT = (addVal table  name (eval2 x table),funcT)
def (Proc name body) table funcT = (table, Map.insert name body funcT)
def (Func name body x) table funcT = case x of
                        REAL -> (addVal table name (R 0.0), Map.insert name body funcT )
                        BOOL -> (addVal table name (B True), Map.insert name body funcT )
def _ _ _ = error "not valid definiton"


evalDefs::[Definition] -> [Map.Map String Value] ->  Map.Map String [Statement] -> ([Map.Map String Value], Map.Map String [Statement] )
evalDefs (x:defs) table funcT = let (s,f) = def x table funcT
                            in evalDefs defs s f
evalDefs [] table funcT = (table,funcT)



interpret :: Program ->String
interpret (defs,prog) = let (table,funcT) = evalDefs defs [Map.empty] Map.empty
                            (output,scope,fun) = evalStatements prog "" table funcT
                            in output
interpret _ = ""


main :: IO ()
main = hspec $ do

  describe "intExp" $ do
    context "adding" $ do
        it "tests addition of two positives" $ do
            intExp (Op2 "+" (Real 1.0) (Real 1.0)) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 2.0)
        
        it "tests addition of positive and negative" $ do
            intExp (Op2 "+" (Real 1.0) (Real (-4.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R (-3.0))

        it "tests addition of two negatives" $ do
            intExp (Op2 "+" (Real (-3.0)) (Real (-1.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R (-4.0))
        
    context "multiply" $ do
        it "multiplies two positives" $ do
            intExp (Op2 "*" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 6.0)

        it "multiplies a positive and negative" $ do
            intExp (Op2 "*" (Real 2.0) (Real (-3.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R (-6.0))

        it "multiplies two negatives" $ do
            intExp (Op2 "*" (Real (-2.0)) (Real (-3.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 6.0)

    context "divide" $ do
        it "divides two positives" $ do
            intExp (Op2 "/" (Real 8.0) (Real 2.0)) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 4.0)

        it "divides a positive and negative" $ do
            intExp (Op2 "/" (Real 8.0) (Real (-2.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R (-4.0))

        it "divides two negatives" $ do
            intExp (Op2 "/" (Real (-8.0)) (Real (-4.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 2.0)

    context "subtract" $ do
        it "subtracts two positives" $ do
            intExp (Op2 "-" (Real 3.0) (Real 1.0)) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 2.0)

        it "subtracts a positive and negative" $ do
            intExp (Op2 "-" (Real 3.0) (Real (-1.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 4.0)

        it "subtracts two negatives" $ do
            intExp (Op2 "-" (Real (-3.0)) (Real (-1.0))) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R (-2.0))

    context "ln" $ do
        it "natural log" $ do
            intExp (Op1 "ln" (Real 1.0) ) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 0.0)
    
    context "sin" $ do
        it "sin" $ do
            intExp (Op1 "sin" (Real 0.0) ) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 0.0)
        
    context "cos" $ do
        it "cos" $ do
            intExp (Op1 "cos" (Real 0.0) ) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 1.0)
    
    context "sqr" $ do
        it "sqr" $ do
            intExp (Op1 "sqr" (Real 4.0) ) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 2.0)
    
    context "exp" $ do
        it "exp" $ do
            intExp (Op2 "exp" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 8.0)
  
  describe "boolExp" $ do
    context "and" $ do
        it "true and false" $ do
            boolExp (OpB "and" (True_C) (False_C)) ([Map.fromList [("string",B False)]]) `shouldBe` (B False)

        it "true and true" $ do
            boolExp (OpB "and" (True_C) (True_C)) ([Map.fromList [("string",B False)]]) `shouldBe` (B True)
    
    context "or" $ do
        it "true or false" $ do
            boolExp (OpB "or" (True_C) (False_C)) ([Map.fromList [("string",B False)]]) `shouldBe` (B True)

        it "false or false" $ do
            boolExp (OpB "or" (False_C) (False_C)) ([Map.fromList [("string",B False)]]) `shouldBe` (B False)

    context ">" $ do
        it "larger greater than lesser" $ do
            boolExp (Comp ">" (Real 3.0) (Real 2.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

        it "lesser greater than larger" $ do
            boolExp (Comp ">" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)

        it "equal greater than equal" $ do
            boolExp (Comp ">" (Real 3.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)

    context "<" $ do
        it "larger less than lesser" $ do
            boolExp (Comp "<" (Real 3.0) (Real 2.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)

        it "lesser less than larger" $ do
            boolExp (Comp "<" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

        it "equal less than equal" $ do
            boolExp (Comp "<" (Real 3.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)

    context ">=" $ do
        it "larger greater than or equal to lesser" $ do
            boolExp (Comp ">=" (Real 3.0) (Real 2.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

        it "lesser greater than or equal to larger" $ do
            boolExp (Comp ">=" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)

        it "equal greater than or equal to equal" $ do
            boolExp (Comp ">=" (Real 3.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

    context "<=" $ do
        it "larger less than or equal to lesser" $ do
            boolExp (Comp "<=" (Real 3.0) (Real 2.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)

        it "lesser less than or equal to larger" $ do
            boolExp (Comp "<=" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

        it "equal less than or equal to equal" $ do
            boolExp (Comp "<=" (Real 3.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

    context "=" $ do
        it "lesser equal to larger" $ do
            boolExp (Comp "=" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)

        it "equal equal to equal" $ do
            boolExp (Comp "=" (Real 3.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

    context "<>" $ do
        it "lesser not equal to larger" $ do
            boolExp (Comp "<>" (Real 2.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B True)

        it "equal not equal to equal" $ do
            boolExp (Comp "<>" (Real 3.0) (Real 3.0)) ([Map.fromList [("string",R 2.0)]]) `shouldBe` (B False)
