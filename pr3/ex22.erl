-module(ex22).
-import(bots,[nou/2]).
-compile(export_all).


%Gestor general

gestioLlums(Pid, Pis) -> receive
	after 3000-> nouProces(apaga,[Pid,Pis,0])
end.

encen(Pid,Pis,10) -> Pid ! {light_on,Pis};
encen(Pid,Pis,T) when T<10 -> receive
after 500 -> Pid ! {light_on, Pis}, nouProces(apaga,[Pid,Pis,T+1])
end.

apaga(Pid,Pis,10) -> Pid ! {light_off,Pis};
apaga(Pid,Pis,T) when T < 10 -> receive
after 500 -> Pid ! {light_off, Pis}, nouProces(encen,[Pid,Pis,T+1])
end.

nouProces(Fun, Par) -> spawn(?MODULE, Fun, Par).

gestionaProcessos(Pid) ->
	receive
		{clicked, Pis} -> Pid ! {light_on, Pis}, nouProces(gestioLlums,[Pid, Pis]), gestionaProcessos(Pid);
		abort -> ok
		
	end.

start() -> gestionaProcessos(bots:nou(6,self())).

