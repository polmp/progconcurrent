-module(motor).
-export([calculaAltura/2,startMotor/1,startMotor/2]).
-include("motor.hrl").

calculaAltura(H0,up) -> H0+(?VELCAB*(?RESOL/1000)); 
calculaAltura(H0,down) -> H0-(?VELCAB*(?RESOL/1000)).

startMotor(H0) -> receive
	run_up -> timer:sleep(?RESOL),io:format("Moviment: Pujant PosActual: ~p~n",[calculaAltura(H0,up)]), sensor ! {at,calculaAltura(H0,up)}, startMotor(calculaAltura(H0,up),runup);
	run_down -> timer:sleep(?RESOL),io:format("Moviment: Baixant PosActual: ~p~n",[calculaAltura(H0,up)]), sensor ! {at,calculaAltura(H0,down)}, startMotor(calculaAltura(H0,down),rundown);
	kill -> sensor ! kill, ok
end.


startMotor(H0,runup) when H0>?MAXREC -> sensor ! at_top, io:format("Moviment: Pujant PosActual: (~p) at_top~n",[H0]),startMotor(H0);
startMotor(H0,runup) ->
	receive
		stop -> sensor ! stopped, io:format("Moviment: Baixant PosActual: STOP (~p)~n",[H0]), startMotor(H0)
	after ?RESOL -> sensor ! {at, calculaAltura(H0,up)}, io:format("Moviment: Pujant PosActual: (~p)~n",[calculaAltura(H0,up)]), startMotor(calculaAltura(H0,up),runup)
end;
startMotor(H0,rundown) when H0<0 -> sensor ! at_bottom, io:format("Moviment: Baixant PosActual: 0 (~p) at_bottom~n",[H0]), startMotor(H0);

startMotor(H0,rundown) -> 
	receive
		stop -> sensor ! stopped, io:format("Moviment: Baixant PosActual: STOP (~p)~n",[H0]), startMotor(H0)
	after ?RESOL -> sensor ! {at,calculaAltura(H0,down)},io:format("Moviment: Baixant PosActual: ~p~n",[calculaAltura(H0,down)]), startMotor(calculaAltura(H0,down),rundown)
end.


