-module(ex23).
-import(bots,[nou/2]).
-compile(export_all).

nouProces(Fun, Par) -> spawn(?MODULE, Fun, Par).
%Sab si es senar o no

esperaValorB2() ->
	receive
		{clicked,0}->io:format("Apreto el 0"), activaBotons(0,on), esperaValorB2();
		{clicked,1}->io:format("Apreto el 1"), activaBotons(1,on), esperaValorB2()
end.

esperaValorB8() ->
	receive
		{clicked,N} when N rem 2 =:= 0->activaBotons(0,off),esperaValorB8();
		{clicked,_} ->activaBotons(1,off),esperaValorB8()
		
end.


				
activaBotons(N,on) -> lists:map(fun(A) -> boto8 ! {light_on, A} end, lists:seq(N,7,2));
activaBotons(N,off) -> lists:map(fun(A) -> boto8 ! {light_off, A} end, lists:seq(N,7,2)).


%start() -> Val = bots:nou(8,self()), ProcApart = nouProces(gestiona, [Val]), bots:nou(2,ProcApart).
start() -> Boto8 = bots:nou(8,nouProces(esperaValorB8,[])), register(boto8, Boto8), Boto2 = bots:nou(2,nouProces(esperaValorB2,[])), register(boto2,Boto2).
