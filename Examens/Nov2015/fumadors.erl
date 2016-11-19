-module(fumadors).
-compile(export_all).

procFumador(Tipus) -> receive
	{Tipus,_}  -> procFumador(Tipus);
	{_,Tipus} -> procFumador(Tipus);
	{A,B} -> io:format("Tinc ~p i agafo ~p i ~p~n",[Tipus,A,B]),liar(),fumar(),procFumador(Tipus)
end.

procProveidor(LlistaPid) -> receive
	ok -> proveidor(LlistaPid),procProveidor(LlistaPid)
end.

% Envia el missatge a tots els PID de la llista
enviaMissatge([Pr],Missatge) -> Pr ! Missatge;
enviaMissatge([Pr|Ul],Missatge) -> Pr ! Missatge, enviaMissatge(Ul,Missatge).

liar() -> io:format("Liant el cigarret...~n"),timer:sleep(100).
fumar() -> io:format("Fumant el cigarret...~n"),timer:sleep(200),central!ok.

%Generem dos productes aleatoris
proveidor(LlistaFumadors) -> Elements=[paper,tabac,llumi], 
PrEl=lists:nth(rand:uniform(3),Elements),SeEl=lists:nth(rand:uniform(2),lists:delete(PrEl,Elements)),enviaMissatge(LlistaFumadors,{PrEl,SeEl}).

creafumador(Tipus) -> spawn(?MODULE, procFumador,[Tipus]).

start() -> LlistaPid=[creafumador(paper),creafumador(tabac),creafumador(llumi)],register(central,spawn(?MODULE, procProveidor,[LlistaPid])),central ! ok. %%Enviem el primer missatge
