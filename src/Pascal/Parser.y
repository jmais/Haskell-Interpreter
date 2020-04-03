{
module Pascal.Parser where

import Pascal.Base
import Pascal.Data
import Pascal.Lexer
}


%name happyParser
%tokentype { Token }


%monad { Parser } { thenP } { returnP }
%lexer { lexer } { Token _ TokenEOF }

%token
        float           { Token _ (TokenFloat $$) }
        ID              { Token _ (TokenID $$)  }
        '+'             { Token _ (TokenOp "+")   }
        '-'             { Token _ (TokenOp "-")   }
        '*'             { Token _ (TokenOp "*")   }
        '/'             { Token _ (TokenOp "/")   }
        '='             { Token _ (TokenOp "=")   }
        '('             { Token _ (TokenK  "(")   }
        ')'             { Token _ (TokenK  ")")   }
        'begin'         { Token _ (TokenK "begin") }
        'end'           { Token _ (TokenK "end")  }
        ':='            { Token _ (TokenOp ":=")   }
        'true'          { Token _ (TokenK "true") }
        'false'         { Token _ (TokenK "false") }
        'and'           { Token _ (TokenK "and") }
        'not'           { Token _ (TokenK "not") }
        'ln'            { Token _ (TokenK "ln") }
        'sqr'           { Token _ (TokenK "sqr") }
        'cos'           { Token _ (TokenK "cos") }
        'sin'           { Token _ (TokenK "sin") }
        'exp'           { Token _ (TokenK "exp")}
        'if'            {Token _ (TokenK "if")}
        'then'          {Token _ (TokenK "then")}
        'else'          {Token _ (TokenK "else")}
        '>'             {Token _ (TokenOp ">")}
        '>='            {Token _ (TokenOp ">=")}
        '<'             {Token _ (TokenOp "<")}
        '<='            {Token _ (TokenOp "<=")}
        '=='            {Token _ (TokenOp "==")}
        '!='            {Token _ (TokenOp "!=")}
        'do'            {Token _ (TokenK "do")}
        'while'         {Token _ (TokenK "while")}
        'for'           {Token _ (TokenK "for")}
        'to'            {Token _ (TokenK "to")}
        'writeln'       {Token _ (TokenK "writeln")}
        'readln'        {Token _ (TokenK "readln")}
        'program'       {Token _ (TokenK "program")}
        ';'             {Token _ (TokenK ";")}
        'var'           {Token _ (TokenK "var")}
        'real'          {Token _ (TokenK "real")}
        'boolean'       {Token _ (TokenK "boolean")}
        ':'             {Token _ (TokenOp ":")}


-- associativity of operators in reverse precedence order
%nonassoc '>' '>=' '<' '<=' '==' '!='
%left '+' '-'
%left '*' '/'
%nonassoc ':='
%%

-- Entry point
Program :: {Program}
    : 'program' ID ';' Def 'begin' Statements 'end' ';' { ($4, $6) }
-- Expressions
Exp :: {Exp}
    : float {Real $1}
    | ID {Var $1} 
    |'+' Exp { $2 } -- ignore Plus
    | '-' Exp { Op1 "-" $2}
    | 'ln'  Exp {Op1 "ln" $2}
    | 'sqr'  Exp {Op1 "sqr" $2}
    | 'sin'  Exp {Op1 "sin" $2}
    | 'cos'  Exp {Op1 "cos" $2}
    | 'exp' Exp Exp {Op2 "exp" $2 $3}
    | Exp '+' Exp { Op2 "+" $1 $3 }
    | Exp '*' Exp { Op2 "*" $1 $3 }
    | Exp '/' Exp { Op2 "/" $1  $3}
    | '(' Exp ')' { $2 } -- ignore brackets

Def::{[Definition]}
: { [] }
| Definition Def {$1:$2}

Definition::{Definition}
: 'var' ID ':'Type ';'  {Dtype $2 $4}
| 'var' ID ':' Type '=' GenExp ';' {Dval $2 $6}

BoolExp :: {BoolExp}
    : 'true' { True_C }
    | 'false' { False_C }
    | ID {V $1}
    | 'not' BoolExp { Not $2 }
    | BoolExp 'and' BoolExp { OpB "and" $1 $3 }
    | Exp '>' Exp { Comp ">" $1 $3 }
    | Exp '>=' Exp { Comp ">=" $1 $3 }
    | Exp '<' Exp { Comp "<" $1 $3 }
    | Exp '<=' Exp { Comp "<=" $1 $3 }
    | Exp '==' Exp { Comp "==" $1 $3 }
    | Exp '!=' Exp { Comp "!=" $1 $3 }

Statements :: {[Statement]}
    : { [] } -- nothing; make empty list
    | Statement Statements { $1:$2 } -- put statement as first element of statements

GenExp :: {GenExp}
    : Exp { FloatExp $1 }
    | BoolExp { BExp $1 }


Type :: {VType}
    : 'boolean' { BOOL }
    | 'real' { REAL }


Statement :: {Statement}
    : ID ':=' GenExp  ';' { Assign $1 $3 } 
    | 'if' '(' BoolExp ')' 'then' Statements 'else' 'begin' Statements 'end' ';' {If $3 $6 $9}
    | 'while' BoolExp 'do' 'begin' Statements 'end' ';' {While $2 $5}
    | 'writeln' '(' GenExp ')' ';' {Write $3}
    | 'readln' '(' GenExp ')' ';' {Read}

{

}