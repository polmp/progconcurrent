-module(ex1).
-export([start/1,esclau/0,nodeCentral/1]).

len([_|A]) -> 1+len(A);
len([]) -> 0.

envia_exit([Pr]) -> Pr ! exit;
envia_exit([Pr|Ul]) -> Pr ! exit, envia_exit(Ul).

esclau() -> receive
	{message,Missatge,N} -> io:format("Soc el proces ~p i rebo ~p~n",[N,Missatge]),node ! {ok,Missatge,N}, esclau();
	exit -> exit
end.

nodeCentral(Lista) ->
	receive
		{message,Missatge} -> lists:nth(1,Lista) ! {message,Missatge,1}, nodeCentral(Lista);
		exit -> envia_exit(Lista),exited;
		{ok,Missatge,N} -> case N+1 =< len(Lista) of true -> io:format("Confirmo missatge (~p) del proces ~p, enviant al seguent (~p)...~n",[Missatge,N,N+1]), lists:nth(N+1, Lista) ! {message,Missatge,N+1},nodeCentral(Lista); false -> io:format("Acabat amb el proces ~p~n",[N]), nodeCentral(Lista) end
	end.

inici(1) -> [spawn(?MODULE,esclau,[])];
inici(N) -> [spawn(?MODULE,esclau,[])] ++ inici(N-1).

start(N) -> LlistaEsclau = inici(N), register(node,spawn(?MODULE,nodeCentral,[LlistaEsclau])), node ! {message,hola}, node.
