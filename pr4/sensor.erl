-module(sensor).
-compile(export_all).
-import(motor,[calculaAltura/2]).
-include("motor.hrl").

%Donada una altura, calcula el sensor que s'ha d'activar. Només envia el missatge 1 cop.
calculaSensor(_,[]) -> undef;
calculaSensor(Altura,[{Num, Alt}|Llista]) -> 
	case calculaAltura(Altura,down) =< Alt of
		true when Altura > Alt -> {Num,Alt};
		true -> calculaSensor(Altura,Llista);
		false -> calculaSensor(Altura,Llista)
	end.

sensorProc(PidAsc) -> receive
	kill -> ok;
	at_top -> PidAsc ! at_top, sensorProc(PidAsc); %al ascensor
	at_bottom -> PidAsc ! at_bottom, sensorProc(PidAsc);
	ready -> PidAsc ! reset, sensorProc(PidAsc); %Quan rebem un ready, acabem d'inicialitzar el motor, enviem un reset al ascensor
	{at,P} -> case calculaSensor(P,[{0,0.5},{1,5.5},{2,8.5},{3,12.5}]) of
		undef -> sensorProc(PidAsc);
		{Val,_} -> io:format("EnvioSensorPis -> ~p~n",[Val]),PidAsc ! {sens_pl,Val},sensorProc(PidAsc)  %Enviem pid al ascensor 
	end 
end.





