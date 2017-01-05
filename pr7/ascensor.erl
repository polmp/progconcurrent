-module(ascensor).
-import(motor,[start/1]).
-import(bppool,[display/2,set_light/3,kill/0,envia_a_tots_excepte/3]).
-import(cdoors,[startPortes/0]).
-export([start/0,abort/0,ascensorProc/3,procesPorta/3,estatReset/1,checkDifferentInList/2,pushed/1,doors_open/0,doors_closed/0,is_closing/0]).

checkDifferentInList(A,[A|G]) -> checkDifferentInList(A,G);
checkDifferentInList(_,List) -> List.

removeLast([]) -> [];
removeLast([_]) -> [] ++ removeLast([]);
removeLast([A|B]) -> [A] ++ removeLast(B).

run_up() -> motor ! run_up.
run_down() -> motor ! run_down.
stop() -> motor ! stop.
light_off(P) -> botonera ! {light_off,P}.
light_on(P) -> botonera ! {light_on,P}.
display(P) -> botonera ! {display,P}.
kill(Var) -> Var ! kill.
killAll() -> stop(),kill(motor),bppool:kill(),kill(wxenv),kill(cdoors),aborted.
abort() -> ascensor ! {abort,bpis1}.
pushed(Pis) -> ascensor ! {clicked,Pis}. 
doors_open() -> ascensor ! doors_opened.
doors_closed() -> ascensor ! doors_closed.

is_closing() -> ascensor ! is_closing.
obre_portes() -> cdoors ! open_doors.
tanca_portes() -> cdoors ! close_doors.
encenPis(Pis) -> set_light(Pis,all,on), light_on(Pis).
apagaPis(Pis) -> set_light(Pis,all,off), light_off(Pis).

ascensorProc(e0,down,Button) -> light_on(Button), run_down(), ascensorProc(e1,Button,[]);

ascensorProc(e0,up,Button) -> light_on(Button), run_up(), ascensorProc(e1,Button,[]);



ascensorProc(e1,Button,List) -> receive
	{sens_pl, Button} -> stop(),display(Button),apagaPis(Button),bppool:display(Button,"HERE"),envia_a_tots_excepte(display,Button,Button),obre_portes(),bppool:display(Button,"OPENING"),procesPorta(Button,opening,List);
	{sens_pl, K} -> display(K), display(Button,K),ascensorProc(e1,Button,List);
	{clicked,N} when List =/= [] -> case N =:= lists:nth(1,lists:reverse(List)) of
			true -> io:format("El pis ja s'ha cridat!~n"), ascensorProc(e1,Button,List);
			false -> encenPis(N), io:format("Aviso Pis ~p quan esta pujant o baixant ~n",[N]),ascensorProc(e1,Button,[N|List]) 
			end;
	{clicked,N} -> encenPis(N), io:format("Aviso Pis ~p quan esta pujant o baixant ~n",[N]),ascensorProc(e1,Button,[N]);
	{abort,bpis1} -> killAll(), kill(botonera);
	abort -> killAll()
end.

procesPorta(BotoAct,close,[]) -> receive
	open_doors -> obre_portes(), bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening,[]);
	close_doors -> procesPorta(BotoAct,close,[]);
	{clicked,Pis} when Pis < BotoAct -> set_light(Pis,all,on),envia_a_tots_excepte(display,"BUSY",Pis),ascensorProc(e0,down,Pis);
	{clicked,Pis} when Pis > BotoAct -> set_light(Pis,all,on),envia_a_tots_excepte(display,"BUSY",Pis),ascensorProc(e0,up,Pis);
	{clicked,BotoAct} -> obre_portes(), bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening,[]);
	{abort,bpis1} -> killAll(), kill(botonera);
	abort -> killAll()
end;

procesPorta(BotoAct,close,List) -> Next = lists:nth(1,lists:reverse(List)), case Next > BotoAct of
	true -> run_up(), envia_a_tots_excepte(display,"BUSY",Next),ascensorProc(e1,Next,removeLast(List));
	false -> run_down(), envia_a_tots_excepte(display,"BUSY",Next),ascensorProc(e1,Next,removeLast(List))
end;

procesPorta(BotoAct,opening,List) -> receive
	doors_opened -> bppool:display(BotoAct,"OPEN"),procesPorta(BotoAct,open,List);
	{clicked,BotoAct} -> procesPorta(BotoAct,opening,List);
	{clicked,Pis} when List =/= [] -> case Pis =:= lists:nth(1,lists:reverse(List)) of
			true -> io:format("El pis ja s'ha cridat!~n"), procesPorta(BotoAct,opening,List);
			false -> encenPis(Pis), io:format("Aviso Pis ~p quan esta obrint ~n",[Pis]),procesPorta(BotoAct,opening,[Pis|List]) 
			end;
	{clicked,Pis} -> encenPis(Pis),io:format("Aviso Pis ~p quan esta obrint ~n",[Pis]),procesPorta(BotoAct,opening,[Pis]);
	{abort,bpis1} -> killAll(), kill(botonera);
	abort -> killAll()
end;

procesPorta(BotoAct,open,List) ->
	receive
		{clicked,BotoAct} -> procesPorta(BotoAct,open,List);
		{clicked,Pis} when List =/= [] -> case Pis =:= lists:nth(1,lists:reverse(List)) of
				true -> io:format("El pis ja s'ha cridat!~n"),procesPorta(BotoAct,open,List);
				false -> encenPis(Pis),io:format("Aviso Pis ~p quan esta obert ~n",[Pis]),procesPorta(BotoAct,open,[Pis|List])
				end;
		{clicked,Pis} -> encenPis(Pis),io:format("Aviso Pis ~p quan esta obert ~n",[Pis]),procesPorta(BotoAct,open,[Pis|List]);
		open_doors -> procesPorta(BotoAct,open,List);
		close_doors -> tanca_portes(),bppool:display(BotoAct,"CLOSING"),procesPorta(BotoAct,closing,List);
		is_closing -> bppool:display(BotoAct,"CLOSING"),procesPorta(BotoAct,closing,List); %Avís de que s'està tancant
		{abort,bpis1} -> killAll(), kill(botonera);
		abort -> killAll()
	
end;

procesPorta(BotoAct,closing,List) ->
	receive
		open_doors -> obre_portes(),bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening,List);
		doors_closed -> bppool:display(BotoAct,"CLOSE"),procesPorta(BotoAct,close,List);
		{clicked,BotoAct} -> obre_portes(), bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening,List);
		{clicked,Pis} when List =/= [] -> case Pis =:= lists:nth(1,lists:reverse(List)) of
				true -> io:format("El pis ja s'ha cridat!~n"),procesPorta(BotoAct,closing,List);
				false -> encenPis(Pis), io:format("Aviso Pis ~p quan esta tancant~n",[Pis]),procesPorta(BotoAct,closing,[Pis|List]) 
				end;
		{clicked,Pis} -> encenPis(Pis),io:format("Aviso Pis ~p quan esta tancant~n",[Pis]), procesPorta(BotoAct,closing,[Pis]);
		{abort,bpis1} -> killAll(), kill(botonera);
		abort -> killAll()
	end.

estatReset(e0) -> receive
	reset -> io:format("Fent reset...~n"), run_down(), estatReset(e1); %Rebem un reset del sensor
	_ -> estatReset(e0)
end;

estatReset(e1) -> receive
	at_bottom -> run_up(), estatReset(e2);
	reset -> io:format("Fent reset...~n"),estatReset(e0);
	{abort,bpis1} -> killAll(), kill(botonera);
	abort -> killAll();
	_ -> estatReset(e1)
end;

estatReset(e2) -> receive
	{sens_pl,0} -> stop(), bppool:display(0,"CLOSE"),procesPorta(0,close,[]);
	{abort,bpis1} -> killAll(), kill(botonera);
	abort -> killAll();
	_ -> estatReset(e2)
end.


start() -> register(ascensor,spawn(?MODULE, estatReset, [e0])),register(botonera,bcab:new(ascensor)),register(sensor,spawn(sensor, sensorProc,[])),register(motor,spawn(motor, startMotor, [2])),sensor ! ready,wxenv:start(), register(cdoors,cdoors:startPortes()),bppool:start(4). 
