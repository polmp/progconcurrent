-module(ex2323).
-compile(export_all).

len([]) -> 0;
len([_|D]) -> 1+len(D).

start(Fun) -> spawn(?MODULE, Fun, []). 

producteEscalar([],[]) -> 0;
producteEscalar([L1|L1F],[L2|L2F]) when is_integer(L1),is_integer(L2)-> case len(L1F) =:= len(L2F) of
	true -> L1*L2 + producteEscalar(L1F,L2F);
	false -> error
end;

producteEscalar(_,_) -> error.

producteEscalar() -> 
	receive
	{From, {L1,L2}} -> From ! producteEscalar(L1,L2)
	end.

pe(L1, L2) -> 
	{Llista11,Llista12} = lists:split(round(len(L1)/2), L1),
	{Llista21,Llista22} = lists:split(round(len(L2)/2), L2),
	Proces1 = start(producteEscalar), %Creem 2 procesos
	Proces2 = start(producteEscalar),
	Proces1 ! {self(),{Llista11,Llista21}},
	Proces2 ! {self(),{Llista12,Llista22}},
	receive
		Val1 -> receive 
				Val2 -> Val1+Val2
			end
	
	end.


esperaValor() -> 
	receive
		{From, SortedList} -> From ! SortedList
	end.

ordena(L, Pid) -> Pid ! {self(),lists:sort(L)},
receive
	SortL -> SortL
end.

ordenaLlista(L) ->
	{Llista1,Llista2} = lists:split(round(len(L)/2), L),
	Sort1 = start(esperaValor),
	Sort2 = start(esperaValor),
	Val1 = ordena(Llista1, Sort1),
	Val2 = ordena(Llista2, Sort2),
	lists:merge(Val1,Val2).



	

	

	


