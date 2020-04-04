-- This file contains the data-structures for the AST
-- The role of the parser is to build the AST (Abstract Syntax Tree) 

module Pascal.Data
    (
        Exp(..),
        BoolExp(..),
        Statement(..),
        addVal,
        getVal,
        addScope,
        addScopeEmpty,
        deleteScope,
        GenExp(..),
        Value(..),
        Definition(..),
        VType(..),
        toFloat,
        toBool,
        deleteScopeFuncs,
        Program
    ) where
import qualified Data.Map.Strict as Map
import Data.Maybe()
-- Data-structure for  numeric expressions
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
    -- TODO: add other statements
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


-- Data-structure for hole program
-- TODO: add declarations and other useful stuff
-- Hint: make a tuple containing the other ingredients
type Program = ([Definition],[Statement])