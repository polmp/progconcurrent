-module(cdoors).
-import(ascensor,[doors_open/0,doors_closed/0]).
-export([startPortes/0,procPortes/1,procPortes/2]).

procPortes(4000,close) -> procPortes(4000);
procPortes(PosActual,close) -> io:format("Tancant portes...~p~n",[PosActual]),receive
	open_doors -> procPortes(PosActual,open);
	kill -> ok;
	_ -> procPortes(PosActual,close)
	after 100 -> procPortes(PosActual+100,close)
end;

procPortes(0,open) -> procPortes(0);
procPortes(PosActual,open) -> io:format("Obrint portes...~p~n",[PosActual]),receive
	close_doors -> procPortes(PosActual,close);
	kill -> ok;
	_ -> procPortes(PosActual,open)
	after 100 -> procPortes(PosActual-100,open)
end.

procPortes(4000) -> ascensor:doors_closed(), receive
	open_doors -> procPortes(4000,open);
	close_doors -> ascensor:doors_closed();
	kill -> ok;
	_ -> procPortes(4000)
	
end;

procPortes(0) -> ascensor:doors_open(), receive
	close_doors -> procPortes(0,close);
	open_doors -> ascensor:doors_open();
	kill -> ok;
	_ -> procPortes(0)
end.

startPortes() -> spawn(?MODULE,procPortes,[4000]).
