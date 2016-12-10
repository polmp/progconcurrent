-module(ascensor).
-import(motor,[start/1]).
-import(bppool,[display/2,set_light/3,kill/0,envia_a_tots_excepte/3]).
-import(cdoors,[startPortes/0]).
-export([start/0,abort/0,ascensorProc/3,ascensorProc/2,procesPorta/2,estatReset/1,checkDifferentInList/2,pushed/1,doors_open/0,doors_closed/0]).

checkDifferentInList(A,[A|G]) -> checkDifferentInList(A,G);
checkDifferentInList(_,List) -> List.


run_up() -> motor ! run_up.
run_down() -> motor ! run_down.
stop() -> motor ! stop.
light_off(P) -> botonera ! {light_off,P}.
light_on(P) -> botonera ! {light_on,P}.
display(P) -> botonera ! {display,P}.
kill(Var) -> Var ! kill.
killAll() -> stop(),kill(motor),cdoors ! abort,aborted.
abort() -> ascensor!{abort,bppool}.
pushed(Pis) -> ascensor ! {clicked,Pis}. 
doors_open() -> ascensor ! doors_opened.
doors_closed() -> ascensor ! doors_closed.
obre_portes() -> cdoors ! open_doors.
tanca_portes() -> cdoors ! close_doors.


ascensorProc(e0,down,Button) -> light_on(Button), run_down(), ascensorProc(e1,Button);

ascensorProc(e0,up,Button) -> light_on(Button), run_up(), ascensorProc(e1,Button).

ascensorProc(e1,Button) -> receive
	{sens_pl, Button} -> stop(),display(Button),light_off(Button), set_light(Button,all,off),bppool:display(Button,"HERE"),envia_a_tots_excepte(display,Button,Button),obre_portes(),bppool:display(Button,"OPENING"),procesPorta(Button,opening);
	{sens_pl, K} -> display(K), display(Button,K),ascensorProc(e1,Button);
	{clicked,_} -> ascensorProc(e1,Button);
	abort -> killAll(),bppool:kill(),wxenv!kill,kill(botonera)
end.

procesPorta(BotoAct,close) -> receive
	open_doors -> obre_portes(), bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening);
	close_doors -> procesPorta(BotoAct,close);
	{clicked,Pis} when Pis < BotoAct -> set_light(Pis,all,on),envia_a_tots_excepte(display,"BUSY",Pis),ascensorProc(e0,down,Pis);
	{clicked,Pis} when Pis > BotoAct -> set_light(Pis,all,on),envia_a_tots_excepte(display,"BUSY",Pis),ascensorProc(e0,up,Pis);
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
		{clicked,BotoAct} -> obre_portes(), bppool:display(BotoAct,"OPENING"),procesPorta(BotoAct,opening);
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






