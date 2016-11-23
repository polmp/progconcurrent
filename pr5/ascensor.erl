-module(ascensor).
-import(motor,[start/1]).
-export([start/0,ascensorProc/1]).

pushedButton(Button) ->
	receive
		at_bottom -> motor ! run_up, pushedButton(0);
		{sens_pl,P} when Button =:= P -> motor ! stop, botonera ! {light_off,P}, botonera ! {display,P}, ascensorProc(P);
		{sens_pl,P} -> botonera ! {display,P}, pushedButton(Button)
	end.

ascensorProc(BotoAct) -> receive
	{clicked,K} when K < BotoAct -> botonera ! {light_on,K}, motor ! run_down, pushedButton(K);
	{clicked,K} when K > BotoAct -> botonera ! {light_on,K}, motor ! run_up, pushedButton(K);
	{clicked,_} -> ascensorProc(BotoAct);
	at_bottom -> motor ! run_up;
	reset -> io:format("Fent reset...~n"), motor ! run_down, pushedButton(288);
	abort -> motor ! kill;
	kill -> motor ! kill, ok
end.

start() -> register(ascensor,spawn(?MODULE, ascensorProc, [1])),register(botonera,bcab:new(4,ascensor)),register(sensor,spawn(sensor, sensorProc,[])),register(motor,spawn(motor, startMotor, [5.5])),sensor ! ready.






