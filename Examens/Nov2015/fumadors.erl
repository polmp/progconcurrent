-module(fumadors).
-export([start/1]).

% Envia el missatge a tots els PID de la llista
enviaMissatge([Pr],Missatge) -> Pr ! Missatge;
enviaMissatge([Pr|Ul],Missatge) -> Pr ! Missatge + enviaMissatge(Ul,Missatge).

liar() -> timer:sleep()

procFumador(Tipus) -> receive
  {Tipus,B} -> procFumador(Tipus);
  {A,Tipus} -> procFumador(Tipus);
  {A,B} -> 
end.

%Generem dos productes aleatoris
proveidor(LlistaFumadors) -> Elements={paper,tabac,llumi}, 
PrEl=lists:sth(rand:uniform(3),Elements),SeEl=lists:sth(rand:uniform(2),lists:remove(PrEl,Elements)),enviaMissatge(LlistaFumadors,{PrEl,SeEl}).

creafumador(Tipus) -> spawn(?MODULE, procFumador,[Tipus]).

start() -> proveidor([creafumador(paper),creafumador(tabac),creafumador(llumi)]).
