-module(fumadors).
-export([start/0,procProveidor/1,procFumador/1]).

procFumador(Tipus) -> receive
	{Tipus,_} -> procFumador(Tipus);
	{_,Tipus} -> procFumador(Tipus);
	{A,B} -> io:format("Tinc ~p i agafo ~p i ~p~n",[Tipus,A,B]),liar(),fumar(),procFumador(Tipus)
	
end.

procProveidor(LlistaPid) -> receive
	ok -> proveidor(LlistaPid),procProveidor(LlistaPid)
end.

% Envia el missatge a tots els PID de la llista
enviaMissatge([Pr],Missatge) -> Pr ! Missatge;
enviaMissatge([Pr|Ul],Missatge) -> Pr ! Missatge, enviaMissatge(Ul,Missatge).

liar() -> io:format("Liant el cigarret...~n"),timer:sleep(500).
fumar() -> io:format("Fumant el cigarret...~n"),timer:sleep(1000),central!ok.

%Genera una tupla amb dos productes (NO pot sortir repetit)
generaAleatori(Elements) -> PrEl=lists:nth(rand:uniform(3),Elements),SeEl=lists:nth(rand:uniform(2),lists:delete(PrEl,Elements)),{PrEl,SeEl}.

%Generem dos productes aleatoris
proveidor(LlistaFumadors) -> Elements=[paper,tabac,llumi], enviaMissatge(LlistaFumadors,generaAleatori(Elements)).

creafumador(Tipus) -> spawn(?MODULE, procFumador,[Tipus]).

start() -> LlistaPid=[creafumador(paper),creafumador(tabac),creafumador(llumi)],register(central,spawn(?MODULE, procProveidor,[LlistaPid])),central ! ok. %%Enviem el primer missatge
