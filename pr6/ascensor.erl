-module(ascensor).
-import(motor,[start/1]).
-import(bppool,[display/2,set_light/3,kill/0,envia_a_tots_excepte/3]).
-import(cdoors,[startPortes/0]).
-export([start/0,ascensorProc/1,abort/0,ascensorProc/3,estatReset/1,checkDifferentInList/2,pushed/1,doors_open/0,doors_closed/0]).

removeLast([]) -> [];
removeLast([_]) -> [] ++ removeLast([]);
removeLast([A|B]) -> [A] ++ removeLast(B).

checkDifferentInList(A,[A|G]) -> checkDifferentInList(A,G);
checkDifferentInList(_,List) -> List.


run_up() -> motor ! run_up.
run_down() -> motor ! run_down.
stop() -> motor ! stop.
light_off(P) -> botonera ! {light_off,P}.
light_on(P) -> botonera ! {light_on,P}.
display(P) -> botonera ! {display,P}.
kill(Var) -> Var ! kill.
killAll() -> stop(),kill(motor),aborted.
abort() -> ascensor!{abort,bppool}.
pushed(Pis) -> ascensor ! {clicked,Pis}. 
doors_open() -> ascensor ! doors_opened.
doors_closed() -> ascensor ! doors_closed.
obre_portes() -> cdoors ! open_doors.
tanca_portes() -> cdoors ! close_doors.


ascensorProc(e0,down,Button) -> light_on(Button), run_down(), ascensorProc(e1,Button,[]);

ascensorProc(e0,up,Button) -> light_on(Button), run_up(), ascensorProc(e1,Button,[]);

ascensorProc(e1,Button,[]) -> receive
	{sens_pl, Button} -> stop(),display(Button),light_off(Button), set_light(Button,all,off),bppool:display(Button,"HERE"),envia_a_tots_excepte(display,Button,Button),obre_portes(),bppool:display(Button,"OPENING"),procesPorta(Button,opening);
	{sens_pl, K} -> display(K), display(Button,K),ascensorProc(e1,Button,[]);
	{clicked,_} -> ascensorProc(e1,Button,[]);
	%Si afegim aquesta linia activem la possibilitat de poder cridar l'ascensor amb cua
	%{clicked,N} -> light_on(N),ascensorProc(e1,Button,[N]);
	abort -> bppool:kill(),killAll()
	%A -> io:format("MISSATGE DESCONEGUT: ~p~n",[A]),ascensorProc(e1,Button)
end;

%AQUEST PROCES S'UTILITZA PER ENCUAR ELS MISSATGES. EN AQUESTA PRÀCTICA NO L'UTILITZEM JA QUE QUAN VA A UN PIS NO REP PETICIONS DELS ALTRES PISOS.
ascensorProc(e1,Button,List) -> receive
	{sens_pl,Button} -> stop(),light_off(Button),display(Button),NextFloor=lists:nth(1,lists:reverse(List)),
		case NextFloor > Button of
			true -> light_on(lists:nth(1,lists:reverse(List))),io:format("Estic al PIS ~p, Desti seguent: ~p~n",[Button,lists:nth(1,lists:reverse(List))]),
				run_up(), ascensorProc(e1,NextFloor,removeLast(List));
			false when NextFloor =:= Button -> 
				ListCheckNext = lists:reverse(checkDifferentInList(Button,lists:reverse(List))),
				if ListCheckNext =/= [] -> 
					Next = lists:nth(1,lists:reverse(ListCheckNext)), light_on(Next),io:format("Hem apretat el mateix, accio -> passem al pis ~p~n",[Next]),
					if Next > NextFloor ->
						run_up(),ascensorProc(e1,Next,removeLast(ListCheckNext));
					Next < NextFloor ->
						run_down(),ascensorProc(e1,Next,removeLast(ListCheckNext))
					end;
				true -> ascensorProc(Button) end;
			false -> light_on(lists:nth(1,lists:reverse(List))),io:format("Estic al PIS ~p, Desti seguent: ~p~n",[Button,lists:nth(1,lists:reverse(List))]),
				run_down(),ascensorProc(e1,NextFloor,removeLast(List))
			end;
		
	{sens_pl, K} -> display(K), display(Button,K),ascensorProc(e1,Button,List);
	{clicked,N} -> light_on(N),ascensorProc(e1,Button,[N|List]);
	abort -> killAll()
end.

ascensorProc(BotoAct) -> receive
	{clicked,K} when K < BotoAct -> set_light(K,all,on),envia_a_tots_excepte(display,"BUSY",K),ascensorProc(e0,down,K);
	{clicked,K} when K > BotoAct -> set_light(K,all,on),envia_a_tots_excepte(display,"BUSY",K),ascensorProc(e0,up,K);
	{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	{clicked,_} -> ascensorProc(BotoAct);
	kill -> ok;
	abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera)
end.

procesPorta(BotoAct,close) -> receive
	open_doors -> obre_portes(), bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening);
	close_doors -> procesPorta(BotoAct,close);
	{clicked,Pis} when Pis < BotoAct -> ascensorProc(e0,down,Pis);
	{clicked,Pis} when Pis > BotoAct -> ascensorProc(e0,up,Pis);
	{clicked,BotoAct} -> obre_portes(), bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening);
	{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	kill -> ok;
	abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera)
end;

procesPorta(BotoAct,opening) -> receive
	doors_opened -> bppool:display(BotoAct,"OPEN"),procesPorta(BotoAct,open);
	{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	kill -> ok;
	abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera)
end;

procesPorta(BotoAct,open) ->
	receive
		{clicked,BotoAct} -> procesPorta(BotoAct,open);
		open_doors -> procesPorta(BotoAct,open);
		close_doors -> tanca_portes(),bppool:display(BotoAct,"CLOSING"),procesPorta(BotoAct,closing);
		{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
		kill -> ok;
		abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera)
	after 10000 -> tanca_portes(),bppool:display(BotoAct,"CLOSING"),procesPorta(BotoAct,closing)
end;

procesPorta(BotoAct,closing) ->
	receive
		open_doors -> obre_portes(),bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening);
		doors_closed -> bppool:display(BotoAct,"CLOSE"),procesPorta(BotoAct,close);
		{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
		kill -> ok;
		abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera)
	end.

estatReset(e0) -> receive
	reset -> io:format("Fent reset...~n"), run_down(), estatReset(e1); %Rebem un reset del sensor
	{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	_ -> estatReset(e0)
end;

estatReset(e1) -> receive
	at_bottom -> run_up(), estatReset(e2);
	reset -> io:format("Fent reset...~n"),estatReset(e0);
	{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	_ -> estatReset(e1)
end;

estatReset(e2) -> receive
	{sens_pl,0} -> stop(), procesPorta(0,close);
	{abort,bppool} -> killAll(),bppool:kill(),wxenv!kill,kill(botonera);
	abort -> killAll(), bppool:kill(),wxenv!kill,kill(botonera); 
	_ -> estatReset(e2)
end.


start() -> register(ascensor,spawn(?MODULE, estatReset, [e0])),register(botonera,bcab:new(4,ascensor)),register(sensor,spawn(sensor, sensorProc,[])),register(motor,spawn(motor, startMotor, [5.5])),sensor ! ready,wxenv:start(), register(cdoors,cdoors:startPortes()),bppool:start(4). 






