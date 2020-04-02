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



eval2 :: GenExp -> [Map.Map String Value] ->  Value
--evalout for statements that add to string
eval2 (FloatExp e1) s = intExp e1 s
eval2 (BExp e1) s = boolExp e1 s

eval :: Statement-> String -> [Map.Map String Value]-> (String,[Map.Map String Value])
eval (Assign name e1) out s = (out, addVal s name (eval2 e1 s))
eval (Block prog) out s = evalStatements prog out s
eval (If b e1 e2) out s = do 
    if toBool(boolExp b s) 
        then evalStatements e1 out s 
        else evalStatements e2 out s
--eval (While b e1)
eval Read out s = (out,s)
eval (Write e1) out s = (out ++ show(eval2 e1 s) ++ "\n",s)
eval _ _ _ = error "not implemented"


evalStatements:: [Statement] -> String -> [Map.Map String Value] -> (String,[Map.Map String Value])
evalStatements (x:xs) out scope = let (output,scopes) = eval x out scope
                                    in evalStatements xs output scopes
evalStatements [] out scope = (out, scope)

interpret :: Program ->String
interpret x = let (output,scope) = evalStatements x "" [Map.empty]
                in output
-- TODO: write the interpreter
interpret []= ""



-- Add acutal scoping logic when doing if statments etc
-- while loops for loops
-- break and continue ( if possible )
-- functions I do not think adding parameters to functions will be easier might not want to do that
-- add semicolon to parser and make part of end of statments
-- add variable definniton block