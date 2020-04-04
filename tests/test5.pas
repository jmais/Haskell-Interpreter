program x;

var x : real = 1.0;
var y : real = 0.0;
begin
    while x < 5.0 do
    begin
        x:= x + 1.0;
        while  y < 4.0 do
        begin
            y := y+1.0;
            writeln(y);
        end;
        writeln(x);
    end;
end;

(*
Output should be 
R 1.0
R 2.0
R 3.0
R 4.0
R 2.0
R 3.0
R 4.0
R 5.0
*)