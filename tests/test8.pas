program testingIfThenElse;

(* Testing: If-Then-Else statements and begin...end blocks *)

begin

if (true) then
    writeln('then');
else
begin
    writeln('else');
end;

if (false) then
    writeln('then');
    writeln('then');
else
    begin
    writeln('else');
    writeln('else');
    end;
end;