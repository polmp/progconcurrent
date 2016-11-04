-module(ex22).
-export([sumaparells/1,sumapossenar/1,duplicaparells/1,boolnegatiu/1]).

sumaparells(L) -> lists:foldl(fun(A,B) -> A+B end,0,lists:filter(fun(A) -> A rem 2 =:= 0 end,L)). %Filtrem llista per nombres parells. Fem suma com a l'exercici 2.1

sumapossenar(L) -> sumapossenar(L,0,1).
sumapossenar([],Acc,_) -> Acc;
sumapossenar([Pr|La],Acc,Pos) when Pos rem 2 /= 0 -> sumapossenar(La,Acc+Pr,Pos+1);
sumapossenar([_|La],Acc,Pos) -> sumapossenar(La,Acc,Pos+1).

treullistes([]) -> [];
treullistes([[H,Q]|T])-> [H,Q] ++ treullistes(T);
treullistes([H|T]) -> [H] ++ treullistes(T).

duplicaparells(L) -> treullistes(lists:map(fun(A) -> if A rem 2 =:= 0 -> lists:duplicate(2,A); true->A end end,L)).

boolnegatiu(L) -> lists:any(fun(A) -> A<0 end, L). % Retorna true si almenys 1 element de la llista és negatiu

