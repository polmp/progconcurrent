-module(motor).
-export([calculaAltura/2,startMotor/1,startMotor/2]).
-include("motor.hrl").

kill(Atom) -> Atom ! kill.
at_top(Var) -> Var ! at_top.
at_bottom(Var) -> Var ! at_bottom.
enviaAltura(Var,Direccio,H0) -> Var ! {at, calculaAltura(H0,Direccio)}.
calculaAltura(H0,up) -> H0+(?VELCAB*(?RESOL/1000)); 
calculaAltura(H0,down) -> H0-(?VELCAB*(?RESOL/1000)).

startMotor(H0) -> receive
	run_up -> timer:sleep(?RESOL),io:format("Moviment: Pujant PosActual: ~p~n",[calculaAltura(H0,up)]), sensor ! {at,calculaAltura(H0,up)}, startMotor(calculaAltura(H0,up),runup);
	run_down -> timer:sleep(?RESOL),io:format("Moviment: Baixant PosActual: ~p~n",[calculaAltura(H0,up)]), sensor ! {at,calculaAltura(H0,down)}, startMotor(calculaAltura(H0,down),rundown);
	kill -> kill(sensor), ok
end.


startMotor(H0,runup) when H0>?MAXREC -> at_top(sensor), io:format("Moviment: Pujant PosActual: (~p) at_top~n",[H0]),startMotor(H0);
startMotor(H0,runup) ->
	receive
		stop -> io:format("Moviment: - PosActual: STOP (~p)~n",[H0]), startMotor(H0)
	after ?RESOL -> enviaAltura(sensor,up,H0), io:format("Moviment: Pujant PosActual: (~p)~n",[calculaAltura(H0,up)]), startMotor(calculaAltura(H0,up),runup)
end;
startMotor(H0,rundown) when H0<0 -> at_bottom(sensor), io:format("Moviment: Baixant PosActual: 0 (~p) at_bottom~n",[H0]), startMotor(H0);

startMotor(H0,rundown) -> 
	receive
		stop -> io:format("Moviment: - PosActual: STOP (~p)~n",[H0]), startMotor(H0)
	after ?RESOL -> enviaAltura(sensor,down,H0),io:format("Moviment: Baixant PosActual: ~p~n",[calculaAltura(H0,down)]), startMotor(calculaAltura(H0,down),rundown)
end.


