-module(ex21).
-export([xenx/2]).

% 1> c(ex21).
% {ok,ex21}
% 2> L=[a,b,c,d,e,f,g,h,i].
% [a,b,c,d,e,f,g,h,i]
% 3> ex21:xenx(L,3).
% [a,d,g]

% Metode 1 Xenx

%xenx([],_,_) -> [];
%xenx([L|U],X,T) -> if (T rem X =:= 0) -> [L] ++ xenx(U,X,T+1); true->xenx(U,X,T+1) end.

%xenx(L,X) -> xenx(L,X,0).

% Variacio metode 1 Xenx

xenx(L,X) -> xenx(L,X,0).

xenx([],_,_) -> [];
xenx([L|U],X,T) when (T rem X) =:= 0 -> [L] ++ xenx(U,X,T+1);
xenx([_|U],X,T) -> xenx(U,X,T+1).