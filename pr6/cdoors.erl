-module(cdoors).
-import(ascensor,[doors_open/0,doors_closed/0]).
-compile(export_all).

procPortes(4000,close) -> procPortes(4000);
procPortes(PosActual,close) -> io:format("Tancant portes...~p~n",[PosActual]),receive
	open -> procPortes(PosActual,open);
	_ -> procPortes(PosActual,close)
	after 100 -> procPortes(PosActual+100,close)
end;

procPortes(0,open) -> procPortes(0);
procPortes(PosActual,open) -> io:format("Obrint portes...~p~n",[PosActual]),receive
	close -> procPortes(PosActual,close);
	_ -> procPortes(PosActual,open)
	after 100 -> procPortes(PosActual-100,open)
end.

procPortes(4000) -> io:format("Portes tancades"), receive
	open -> procPortes(4000,open);
	_ -> procPortes(4000)
	
end;

procPortes(0) -> io:format("Portes obertes"), receive
	close -> procPortes(0,close);
	_ -> procPortes(0)
end.



start() -> spawn(?MODULE,procPortes,[4000]).
