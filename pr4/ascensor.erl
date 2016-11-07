-module(ascensor).
-import(motor,[start/1]).
-compile(export_all).

pushedButton(Button) ->
	receive
		at_bottom -> pidmotor ! run_up, pushedButton(0);
		{sens_pl,P} when Button =:= P -> pidmotor ! stop, botonera ! {light_off,P}, botonera ! {display,P}, ascensorProc(P);
		{sens_pl,P} -> botonera ! {display,P}, pushedButton(Button)
	end.

ascensorProc(BotoAct) -> receive
	{clicked,K} when K < BotoAct -> botonera ! {light_on,K}, pidmotor ! run_down, pushedButton(K);
	{clicked,K} when K > BotoAct -> botonera ! {light_on,K}, pidmotor ! run_up, pushedButton(K);
	{clicked,_} -> ascensorProc(BotoAct);
	at_bottom -> pidmotor ! run_up;
	reset -> io:format("Fent reset...~n"),pidmotor ! run_down, pushedButton(288);
	abort -> pidmotor ! kill;
	kill -> pidmotor ! kill, ok
end.

startAll() -> ProcAsc=spawn(?MODULE, ascensorProc, [1]),PidSens = spawn(sensor, sensorProc,[ProcAsc]), register(pidmotor,motor:start(PidSens)),register(botonera,bcab:new(4,ProcAsc)).






