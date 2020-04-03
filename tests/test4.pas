program test4;

var A : real;

begin
for b := 5.0 to 10.0 do
begin
    A:=A+5.0;
end;
writeln(A);
writeln(b);
end;

(* output is 
 R 25.0
 Id not in scope*)