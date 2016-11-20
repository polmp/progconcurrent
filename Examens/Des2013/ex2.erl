-module(ex2).
-compile(export_all).

len([_|T]) -> 1+len(T);
len([]) -> 0.

%Retorna el PID del esclau amb identificador N
buscaEsclau([],_) -> notfound;
buscaEsclau([{N,Pid}|_],N) -> Pid;
buscaEsclau([_|Resta],N) -> buscaEsclau(Resta,N).

esclau() ->
	receive
		{morir,N} -> io:format("El màster ha reiniciat l'esclau ~p~n",[N]), master! {mort,N};
		{Message,N} -> io:format("L'esclau ~p ha rebut el missatge ~p~n",[N,Message]), esclau()
		
	end.

to_slave(Missatge,N) -> master ! {Missatge,N}.

procMaster(LlistaPid) -> receive
	{mort, N} -> procMaster([{N,spawn(?MODULE,esclau,[])}|LlistaPid]);
	{Missatge,N} -> case N =< len(LlistaPid) of
		true -> Pid = buscaEsclau(LlistaPid,N), Pid ! {Missatge,N},procMaster(LlistaPid); 
		false -> io:format("DEP"), procMaster(LlistaPid) end
	
end.

creaEsclau(1) -> [{1,spawn(?MODULE,esclau,[])}];
creaEsclau(N) -> [{N,spawn(?MODULE,esclau,[])}] ++ creaEsclau(N-1).

start(N) -> LlistaPid = creaEsclau(N), register(master, spawn(?MODULE, procMaster, [LlistaPid])).

