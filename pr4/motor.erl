-module(motor).
-export([calculaAltura/2,startMotor/2,start/1]).
-include("motor.hrl").

calculaAltura(H0,up) -> H0+(?VELCAB*(?RESOL/1000)); 
calculaAltura(H0,down) -> H0-(?VELCAB*(?RESOL/1000)).

startMotor(Pid,H0) -> receive
	run_up -> timer:sleep(?RESOL),io:format("Moviment: Pujant PosActual: ~p~n",[calculaAltura(H0,up)]), Pid ! {at,calculaAltura(H0,up)}, startMotor(Pid,calculaAltura(H0,up),runup);
	run_down -> timer:sleep(?RESOL),io:format("Moviment: Baixant PosActual: ~p~n",[calculaAltura(H0,up)]), Pid ! {at,calculaAltura(H0,down)}, startMotor(Pid,calculaAltura(H0,down),rundown);
	kill -> Pid ! kill, ok
end.


startMotor(Pid,H0,runup) when H0>?MAXREC -> Pid ! at_top, io:format("Moviment: Pujant PosActual: (~p) at_top~n",[H0]),startMotor(Pid,H0);
startMotor(Pid,H0,runup) ->
	receive
		stop -> Pid ! stopped, io:format("Moviment: Baixant PosActual: STOP (~p)~n",[H0]), startMotor(Pid,H0)
	after ?RESOL -> Pid ! {at, calculaAltura(H0,up)}, io:format("Moviment: Pujant PosActual: (~p)~n",[calculaAltura(H0,up)]), startMotor(Pid,calculaAltura(H0,up),runup)
end;
startMotor(Pid,H0,rundown) when H0<0 -> Pid ! at_bottom, io:format("Moviment: Baixant PosActual: 0 (~p) at_bottom~n",[H0]), startMotor(Pid,H0);

startMotor(Pid,H0,rundown) -> 
	receive
		stop -> Pid ! stopped, io:format("Moviment: Baixant PosActual: STOP (~p)~n",[H0]), startMotor(Pid,H0)
	after ?RESOL -> Pid ! {at,calculaAltura(H0,down)},io:format("Moviment: Baixant PosActual: ~p~n",[calculaAltura(H0,down)]), startMotor(Pid,calculaAltura(H0,down),rundown)
end.

start(Pid) -> Func=spawn(?MODULE, startMotor, [Pid,5.5]), Pid ! ready,Func.


