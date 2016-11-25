-module(ascensor).
-import(motor,[start/1]).
-export([start/0,ascensorProc/1,ascensorProc/2,ascensorProc/3,estatReset/1]).

run_up() -> motor ! run_up.
run_down() -> motor ! run_down.
stop() -> motor ! stop.
light_off(P) -> botonera ! {light_off,P}.
light_on(P) -> botonera ! {light_on,P}.
display(P) -> botonera ! {display,P}.
kill(Var) -> Var ! kill.

ascensorProc(e0,down,Button) -> light_on(Button), run_down(), ascensorProc(e1,Button);

ascensorProc(e0,up,Button) -> light_on(Button), run_up(), ascensorProc(e1,Button).

ascensorProc(e1,Button) -> receive
	{sens_pl, Button} -> stop(),display(Button),light_off(Button), ascensorProc(Button);
	{sens_pl, K} -> display(K), ascensorProc(e1,Button);
	abort -> stop(),kill(motor),aborted
	%A -> io:format("MISSATGE DESCONEGUT: ~p~n",[A]),ascensorProc(e1,Button)
end.

ascensorProc(BotoAct) -> receive
	{clicked,K} when K < BotoAct -> ascensorProc(e0,down,K);
	{clicked,K} when K > BotoAct -> ascensorProc(e0,up,K);
	{clicked,_} -> ascensorProc(BotoAct);
	kill -> ok;
	abort -> stop(),kill(motor),ok
end.

estatReset(e0) -> receive
	reset -> io:format("Fent reset...~n"), run_down(), estatReset(e1); %Rebem un reset del sensor
	_ -> estatReset(e0)
end;

estatReset(e1) -> receive
	at_bottom -> run_up(), estatReset(e2);
	reset -> io:format("Fent reset...~n"),estatReset(e0);
	_ -> estatReset(e1)
end;

estatReset(e2) -> receive
	{sens_pl,0} -> stop(), ascensorProc(0); 
	_ -> estatReset(e2)
end.


start() -> register(ascensor,spawn(?MODULE, estatReset, [e0])),register(botonera,bcab:new(4,ascensor)),register(sensor,spawn(sensor, sensorProc,[])),register(motor,spawn(motor, startMotor, [5.5])),sensor ! ready,initial_reset. 






