program testingBooleanExpressions;

(* Testing: boolean expressions and operator precedence *)

var x : boolean = true;
var y : boolean = false;
var z : boolean;

begin
z := x and y;
writeln(z);
//false
z := x or y;
writeln(z);
//true
z := false and x or x;
writeln(z);
//true
z := false and (x or x);
writeln(z);
//false
z := x or y and true;
writeln(z); 
//true
z := not x and not false or true and x;
writeln(z);
//true
z := not (x and not false or true and x);
writeln(z);
//true
end;
