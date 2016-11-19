-module(fumadors2).
-export([start/0, procFumador/0, procProveidor/1]).

procFumador() -> receive
	{smoke,B} -> io:format("Tinc ~p~n",[B]),liar(),fumar(),central!ok,procFumador()
end.

procProveidor(LlistaPid) -> receive
	ok -> proveidor(LlistaPid),procProveidor(LlistaPid)
end.

liar() -> io:format("Liant el cigarret...~n"),timer:sleep(500).
fumar() -> io:format("Fumant el cigarret...~n"),timer:sleep(1000).

%Genera una tupla amb dos productes (pot sortir repetit)
generaAleatori(Elements,true) -> {lists:nth(rand:uniform(3),Elements), lists:nth(rand:uniform(3),Elements)};
%Genera una tupla amb dos productes (NO pot sortir repetit)
generaAleatori(Elements,false) -> PrEl=lists:nth(rand:uniform(3),Elements),SeEl=lists:nth(rand:uniform(2),lists:delete(PrEl,Elements)),{PrEl,SeEl}.

%Retorna el PID del procés que ha de fumar. {Undef,RepEl} si l'element RepEl és repetit
hadeFumar([],RepEl) -> {undef,RepEl};
hadeFumar([{El,Pid}|R],Tupla) -> 
	if 
		(element(1,Tupla) =:= element(2,Tupla)) -> hadeFumar([],element(1,Tupla));
		(element(1,Tupla) =/= El) and (element(2,Tupla) =/= El) -> {El,Pid};
		true -> hadeFumar(R,Tupla)
	end.

proveidor(LlistaFumadors) -> Elements=[paper,tabac,llumi], TupAl = generaAleatori(Elements,true), 
	case hadeFumar(LlistaFumadors,TupAl) of 
		{undef,RepEl} -> io:format("Element del subministrador repetit (~p)~n",[RepEl]),proveidor(LlistaFumadors);
		{El,Pid} -> Pid ! {smoke,El}
end.

creafumador() -> spawn(?MODULE, procFumador,[]).

start() -> LlistaPid=[{paper,creafumador()},{tabac,creafumador()},{llumi,creafumador()}],register(central,spawn(?MODULE, procProveidor,[LlistaPid])),central ! ok. %%Enviem el primer missatge