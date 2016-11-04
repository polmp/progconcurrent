-module(ex23).
-export([producteEscalar/2]).

len([]) -> 0;
len([_|L]) -> 1+len(L).

producteEscalar([],[]) -> 0;
producteEscalar([L1|L1F],[L2|L2F]) -> case len(L1F) =:= len(L2F) of
	true -> L1*L2 + producteEscalar(L1F,L2F);
	false -> error
end.
	