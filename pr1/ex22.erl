-module(ex22).
-export([buida/1, empila/2, desempila/1, cim/1, start/0, converteixllista/1]).

% Implementació pila de la pràctica anterior. Modificarem les funcions per realitzar les operacions

buida(_) -> [].

empila('+',[V1,V2|L]) -> [V1+V2|L];
empila('*',[V1,V2|L]) -> [V1*V2|L];
empila(V,L) -> [V|L].

desempila([]) -> [];
desempila([_|U]) -> U. 

cim([]) -> [];
cim([P|_]) -> P.

% Converteix la llista en un Stack
converteixllista({ok,[],_}) -> [];
converteixllista({ok,[{_,_,Value}|Q],T}) -> [Value] ++ converteixllista({ok,Q,T});
converteixllista({ok,[{Sign,_}|Q],T}) when Sign =:= '+'; Sign =:= '*' -> [Sign] ++ converteixllista({ok,Q,T});
converteixllista({ok,[{_,_}|Q],T}) -> converteixllista({ok,Q,T}).

%opera(L) -> [Resultat] = lists:foldl(fun empila/2, [], L), Resultat.

opera(L) -> [Resultat] = lists:foldl(fun empila/2, [], converteixllista(L)), Resultat.

start() -> opera(io:scan_erl_exprs('expressio> ')).
