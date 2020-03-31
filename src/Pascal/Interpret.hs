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

intExp :: Exp ->Map.Map String Value -> Value
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

boolExp:: BoolExp->Map.Map String Value-> Value
boolExp (True_C) _ = (B True)
boolExp (False_C) _ = (B False)
boolExp (Not exp) s = error "not implemented"
boolExp (V e1) s = (getVal s e1)
boolExp ( OpB "and" e1 e2) s = (B $ toBool(boolExp e1 s) && toBool(boolExp e2 s))
boolExp (Comp ">" e1 e2) s = (B (toFloat(intExp e1 s) > toFloat(intExp e2 s)))



eval2 :: GenExp -> Map.Map String Value ->  Value
--evalout for statements that add to string
eval2 (FloatExp e1) s = intExp e1 s
eval2 (BExp e1) s = boolExp e1 s

eval :: Statement-> Map.Map String Value-> Map.Map String Value
eval (Assign name e1) s = addVal s name (eval2 e1 s)
eval (Block prog) s = interpret prog s
eval (If b e1 e2) s = do 
    if toBool(boolExp b s) 
        then interpret e1 s 
        else interpret e2 s
eval (While b e1) 
eval _ _ = error "not implemented"


interpret :: Program -> Map.Map String Value-> Map.Map String Value
interpret [x] s = eval x s
interpret (x:xs) s = interpret xs (eval x s)
-- TODO: write the interpreter
interpret _ _ = Map.empty