program test7;
var x : real = 2.0;
var y : real = 3.0;
var z : real;

function first():real
begin
 x := 2.0;
 y := 3.0;
 z := 4.0 * y / x / (5.0 * x);
 writeln(z); (*output should be 0.6*)
end;

function second():real
begin
x := 2.0;
y := 3.0;
z := 4.0 * y / x / 5.0 * x;
writeln(z); (* output should be 2.4 *)
end;


begin
first();
second();
end;