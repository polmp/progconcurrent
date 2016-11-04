-module(ex21).
-export([suma/1]).


fold([],_,I) -> I;
fold([C|Cua], F, I) -> fold(Cua,F,F(C,I)).

suma(L) -> fold(L, fun(A,B) -> A+B end, 0).
