-module(patata).
-compile(export_all).

len([_|T]) -> 1+len(T);
len([]) -> 0.

procusuari() -> receive
	{received,0,Data} -> io:format("Usuari ~p DEP~n",[element(1,Data)]),central ! {dep,Data};
	{received,Patata,Data} -> io:format("Usuari ~p rep patata ~p~n",[element(1,Data),Patata]),central ! {patata,Patata-1,Data},procusuari()
end.

%%Envia una patata amb valor aleatori a un usuari aleatori de LlistaPid
enviaPatata(LlistaPid,random) -> Usuari=rand:uniform(len(LlistaPid)),Patata=rand:uniform(6),{_,Pidpat}=lists:nth(Usuari,LlistaPid),Pidpat !{received,Patata,lists:nth(Usuari,LlistaPid)};

%%Envia una patata de valor N a un usuari aleatori de LlistaPid
enviaPatata(LlistaPid,N) -> Usuari = rand:uniform(len(LlistaPid)), {_,Pid}=lists:nth(Usuari,LlistaPid),Pid ! {received,N,lists:nth(Usuari,LlistaPid)}. 

central([_]) -> receive
	{patata,N,Data} -> io:format("El jugador ~p ha guanyat! Valor patata: ~p~n",[element(1,Data),N+1])
end;

central(LlistaPid) -> receive
	{patata,Patata,_} -> io:format("Patata té el valor ~p. Enviant a persona random~n",[Patata]), enviaPatata(LlistaPid,Patata), central(LlistaPid);
	{dep,Data} -> NouLlista = lists:delete(Data,LlistaPid), enviaPatata(NouLlista,random),central(NouLlista)
end.

generaProcessos(N) -> generaProcessos(N,[]).
generaProcessos(0,L) -> L;
generaProcessos(N,L) -> generaProcessos(N-1,[{N,spawn(?MODULE,procusuari,[])}|L]).

%%A l'inici, generem la primera patata aleatòria i la enviem a un usuari
inici(N) -> LlistaPid=generaProcessos(N),
	register(central,spawn(?MODULE,central,[LlistaPid])),enviaPatata(LlistaPid,random).
