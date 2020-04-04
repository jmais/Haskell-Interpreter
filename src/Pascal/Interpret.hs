module Pascal.Interpret 
(
    interpret
)
where
import Pascal.Data
import qualified Data.Map.Strict as Map

-- TODO: define auxiliary functions to aid interpretation
-- Feel free to put them here or in different modules
-- Hint: write separate evaluators for numeric and
-- boolean expressions and for statements

-- make sure you write test unit cases for all functions

intExp :: Exp ->[Map.Map String Value] -> Value
intExp (Real e1) _ =(R e1)
intExp (Var e1) s =(getVal s e1)
intExp (Op1 "ln" e1) s = (R (log (toFloat(intExp e1 s))))
intExp (Op1 "sin" e1) s = (R (sin (toFloat(intExp e1 s))))
intExp (Op1 "cos" e1) s = (R (cos (toFloat(intExp e1 s))))
intExp (Op1 "sqrt" e1) s = (R (sqrt (toFloat(intExp e1 s))))
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
boolExp (Comp "==" e1 e2) s = (B (toFloat(intExp e1 s) == toFloat(intExp e2 s)))
boolExp (Comp "!=" e1 e2) s = (B (toFloat(intExp e1 s) /= toFloat(intExp e2 s)))
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
-- TODO: write the interpreter
interpret _ = ""



-- for loops
-- break and continue ( if possible )
-- functions I do not think adding parameters to functions will be easier might not want to do that