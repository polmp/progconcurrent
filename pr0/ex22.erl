-module(ex22).
-export([buida/1, empila/2, desempila/1, cim/1]).

% Implementació pila
% Considerarem que el primer element de la llista és el últim valor afegit

buida(_) -> [].

empila(V,L) -> [V] ++ L.

desempila([]) -> [];
desempila([_|U]) -> U. 

cim([P|_]) -> P.