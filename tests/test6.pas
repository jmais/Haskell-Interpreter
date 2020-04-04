program hello;

var x: real = 4.0;
var y: real;

begin
    writeln('ln of x');
    y:= ln x;
    writeln(y);
    writeln('sqr of x');
    y:= sqr x;
    writeln(y);
    writeln('cos of x');
    y:= cos x;
    writeln(y);
    writeln('sin of x');
    y:= sin x;
    writeln(y);
    writeln('x squared');
    y:= exp x 2.0;
    writeln(y);
end;

(* output should be
'ln of x'
R 1.3862944
'sqr of x'
R 2.0
'cos of x'
R (-0.6536436)
'sin of x'
R (-0.7568025)
'x squared'
R 16.0
*)