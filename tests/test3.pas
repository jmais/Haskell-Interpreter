program test3;

var A : real;
var B : boolean;
var D : real = 4.0;
var C : boolean = false;


begin
    writeln(A);
    writeln(B);
    writeln(D);
    writeln(C);
    while D > A do
    begin
    writeln(A);
    A:= A + 1.0;
    Z:=A;
    end;
    writeln(A);
    writeln(Z);

end;