-module(sensor).
-export([sensorProc/0]).
-import(motor,[calculaAltura/2]).
-include("motor.hrl").

at_top() -> ascensor ! at_top.
at_bottom() -> ascensor ! at_bottom.
reset() -> ascensor ! reset.
sens_pl(Val) -> ascensor ! {sens_pl,Val}.

%Donada una altura, calcula el sensor que s'ha d'activar. Només envia el missatge 1 cop.
calculaSensor(_,[]) -> undef;
calculaSensor(Altura,[{Num, Alt}|Llista]) -> 
	case calculaAltura(Altura,down) =< Alt of
		true when Altura > Alt -> {Num,Alt};
		true -> calculaSensor(Altura,Llista);
		false -> calculaSensor(Altura,Llista)
	end.

sensorProc() -> receive
	kill -> ok;
	at_top -> at_top(), sensorProc(); %al ascensor
	at_bottom -> at_bottom(), sensorProc();
	ready -> reset(), sensorProc(); %Quan rebem un ready, acabem d'inicialitzar el motor, enviem un reset al ascensor
	{at,P} -> case calculaSensor(P,[{0,0.5},{1,5.5},{2,8.5},{3,12.5}]) of
		undef -> sensorProc();
		{Val,_} -> io:format("EnvioSensorPis -> ~p~n",[Val]),sens_pl(Val),sensorProc()  %Enviem pid al ascensor 
	end 
end.





