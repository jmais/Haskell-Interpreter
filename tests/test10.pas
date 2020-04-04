program test10;

var x: real = 2.0;
var y: real = 3.0;

begin
    writeln(x<y);
    writeln(x>y);
    writeln(x<x);
    writeln(x<=y);
    writeln(x>=y);
    writeln(x!=y);
    writeln(x==y);

end;

(* 
output should be

B True
B False
B False
B True
B False
B True
B False
*)