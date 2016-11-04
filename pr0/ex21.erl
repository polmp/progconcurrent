-module(ex21).
-export([compta/1, suprimeix/2]).

%% Compta

%% compta(L) -> retorna la longitud de la llista L.
%% L -> llista

%Metode 1 Compta
compta(L) -> compta(L,0).
compta([], Sum) -> Sum;
compta([_|C], Sum) -> compta(C, Sum+1).

% Metode 2 Compta
%%compta([]) -> 0;
%%compta([_|C]) -> 1 + compta(C).


% Suprimeix
%%  suprimeix(L,E) -> retorna una llista amb els mateixos elements que L després d'haver suprimit l'element E

% Metode 1 Suprimeix
% suprimeix([],_) -> [];
% suprimeix(L,E) -> [R || R <- L, R /= E].

% Metode 2 Suprimeix

%suprimeix(L,E) -> lists:reverse(suprimeix(L,E,[])).
%suprimeix([],_,Sum) -> Sum;
%suprimeix([A|B],L,Sum) when A /= L -> suprimeix(B,L,[A|Sum]);
%suprimeix([_|B],L,Sum) -> suprimeix(B, L, Sum).

% Metode 3

suprimeix([],_) -> [];
suprimeix([L|D],E) when L /= E -> [L]++suprimeix(D, E);
suprimeix([_|D],E) -> suprimeix(D,E). 



