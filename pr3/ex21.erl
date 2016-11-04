-module(ex21).
-import(bots, [nou/2]).
-export([start/0]).

%Ilumina tots els pisos fins el pis 10

apagaTots(Pid,9) -> Pid ! {light_off, 9}, gest(Pid);
apagaTots(Pid,Value) when Value < 10 -> Pid ! {light_off, Value}, apagaTots(Pid, Value+1).


esperaBotoEnces(Pid,Start) -> 
	receive
		{clicked, Pis} when Pis >= Start -> apagaTots(Pid,0);
		{clicked, _} -> esperaBotoEnces(Pid, Start)
	end.

ilumina(Pid, NombrePis, Start) when NombrePis < 9 -> Pid ! {light_on,NombrePis}, ilumina(Pid,NombrePis+1,Start);
ilumina(Pid,9,Start) -> Pid ! {light_on,9}, esperaBotoEnces(Pid, Start).


gest(Pid) -> receive
	{clicked,Pis} -> ilumina(Pid, Pis, Pis)
end.

start() -> gest(bots:nou(10,self())).





