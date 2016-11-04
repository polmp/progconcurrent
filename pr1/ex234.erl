-module(ex234).
-compile(export_all).

%A = {1,fun (0,$a) -> 0; (0,$b) -> 1; (_,_)->undef end}.

check({Estat, Anon}, String) -> check({Estat, Anon}, String, 0).

check({_,_},_,undef) -> undef;
check({Estat,_},[], EstatAct) when EstatAct =:= Estat -> true;
check({_,_},[], _) -> false;

check({Estat,Anon},[Pri|Res], EstatAct) -> check({Estat, Anon}, Res, Anon(EstatAct,Pri)).

makeparser(A) -> fun(T) -> case check(A, T) of
	undef -> false;
	true -> true;
	false -> false end end.
	
	