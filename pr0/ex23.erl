-module(ex23).
-export([saberPreu/2, saberQuantitat/2, nombreTotalProductes/1]).


% Gestió de magatzem
% Tenim una llista de tuples que té aquesta sintaxi: [{id producte, quantitat_que_en_resta, preu}]
% Per exemple podríem implementar les següents funcions:
% saberPreu(IdProducte, Tupla) -> Retorna el preu del producte amb id producte
% saberQuantitat(IdProducte, Tupla) -> Retorna la quantitat del producte amb id producte
% nombreTotalProductes(Tupla) -> Retorna el total de productes que hi ha al magatzem

%% Exemple execució
% >> Magatzem=[{1,6,50},{2,7,20},{3,7,25}].
% [{1,6,50},{2,7,20},{3,7,25}]
% ex23:saberPreu(2,Magatzem).
% 20
% ex23:saberQuantitat(1,Magatzem).
% 6
% f().
% ok
% Magatzem=[{1,6,50},{2,7,20},{3,7,25},{4,6,50},{5,80,400}].
% ex23:nombreTotalProductes(Magatzem).
% 106

saberPreu(_,[]) -> -1; % Preu indefinit
saberPreu(Id,[{IdPr,_,P}|R]) -> if IdPr =:= Id -> P; true->saberPreu(Id,R) end. 

saberQuantitat(_,[]) -> 0; % No hi ha cap tipus de quantitat
saberQuantitat(Id,[{IdPr,Q,_}|R]) -> if IdPr =:= Id -> Q; true->saberQuantitat(Id,R) end.

nombreTotalProductes([]) -> 0;
nombreTotalProductes([{_,Q,_}|R]) -> Q + nombreTotalProductes(R).
