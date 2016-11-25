-module(ascensor).
-import(motor,[start/1]).
-export([start/0,ascensorProc/1]).

run_up() -> motor ! run_up.
run_down() -> motor ! run_down.
stop() -> motor ! stop.
light_off(P) -> botonera ! {light_off,P}.
light_on(P) -> botonera ! {light_on,P}.
display(P) -> botonera ! {display,P}.
kill(Var) -> Var ! kill.

pushedButton(Button) ->
	receive
		at_bottom -> run_up(), pushedButton(0);
		{sens_pl,P} when Button =:= P -> stop(), light_off(P), display(P), ascensorProc(P);
		{sens_pl,P} -> display(P), pushedButton(Button);
		abort -> stop(), kill(motor), kill(ascensor) %Rebem abort de la botonera quan estem fent. Motor ja fa kill de sensor
	end.

ascensorProc(BotoAct) -> receive
	{clicked,K} when K < BotoAct -> light_on(K), run_down(), pushedButton(K);
	{clicked,K} when K > BotoAct -> light_on(K), run_up(), pushedButton(K);
	{clicked,_} -> ascensorProc(BotoAct);
	at_bottom -> run_up();
	reset -> io:format("Fent reset...~n"), run_down(), pushedButton(288);
	kill -> ok;
	abort -> stop(),kill(motor),ok
end.

start() -> register(ascensor,spawn(?MODULE, ascensorProc, [1])),register(botonera,bcab:new(4,ascensor)),register(sensor,spawn(sensor, sensorProc,[])),register(motor,spawn(motor, startMotor, [5.5])),sensor ! ready.






