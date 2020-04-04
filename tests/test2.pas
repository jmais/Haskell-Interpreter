program test1;

procedure print ()
begin
    A:=5.0;
    writeln(B);
    writeln(A);
end;

var B: real = 6.0;

begin
    print();
    writeln(B);
end;

(* output
Id not in scope
*)