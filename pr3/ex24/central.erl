-module(central).
-compile(export_all).

nouProces(Fun,Par) -> spawn(?MODULE, Fun, Par). % nouProces(FuncioAnonima, [Var1,VarN])

boto2() ->
	receive
		{clicked,0} -> botcentral ! new, boto2();
		{clicked,1} -> botcentral ! close, boto2();
		abort -> botcentral ! close, botcentral ! apagaproces
	end.

procesIndividual() -> receive
	{clicked,N} -> botcentral ! {pushedbutton,N}, procesIndividual();
	abort -> io:format("Tancat")
end.

actuaBotons(Llista, N, on) -> lists:map(fun(A) -> A ! {light_on,N} end, Llista);
actuaBotons(Llista, N, off) -> lists:map(fun(A) -> A ! {light_off,N} end, Llista).

initBotonera(Pid,LlistaEncesos) -> lists:map(fun(A) -> Pid ! {light_on,A} end,LlistaEncesos).

botoneraCentral(Llista,LlistaEncesos) -> receive
	new -> NouProc=bots:nou(8, nouProces(procesIndividual,[])), initBotonera(NouProc, LlistaEncesos),botoneraCentral([NouProc|Llista],LlistaEncesos);
	close -> lists:map(fun(A) -> A ! close end, Llista), botoneraCentral([],[]);
	{light_on,N} -> actuaBotons(Llista,N,on), botoneraCentral(Llista, [N|LlistaEncesos]);
	{light_off,N} -> actuaBotons(Llista,N,off), botoneraCentral(Llista,LlistaEncesos -- [N]);
	apagaproces -> io:format("RIP");
	{pushedbutton,N} -> case lists:member(N, LlistaEncesos) of
		true -> actuaBotons(Llista,N,off), botoneraCentral(Llista,LlistaEncesos -- [N]);
		false -> actuaBotons(Llista,N,on),botoneraCentral(Llista,[N|LlistaEncesos])
	end
end.

creaBotoneraCentral() -> BotCentral = nouProces(botoneraCentral,[[],[]]), register(botcentral,BotCentral), BotCentral. % Genera botonera central

botCentral() -> creaBotoneraCentral(), bots:nou(2, nouProces(boto2,[])).
