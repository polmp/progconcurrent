-module(bppool).
-export([procPisos/1,start/1,display/2,envia_a_tots/2,set_light/3,kill/0,envia_a_tots_excepte/3]).

envia_a_tots([Pr],M) -> Pr ! M;
envia_a_tots([Pr|Ul],M) -> Pr ! M, envia_a_tots(Ul,M).

envia_a_tots_excepte(display,M,N) -> bppool ! {sent_except,display,M,N+1}.

envia_a_tots_excepte([],_,_,_,_) -> [];
envia_a_tots_excepte([_|Ul],display,M,N,N) -> envia_a_tots_excepte(Ul,display,M,N,N+1);
envia_a_tots_excepte([Pr|Ul],display,M,N,Pos) -> Pr ! M, envia_a_tots_excepte(Ul,display,M,N,Pos+1).

display(N,M) -> bppool ! {display,N,M}.
set_light(Pis,Dir,State) -> bppool ! {set_light,Pis,Dir,State}.
kill() -> bppool ! kill. 

procPisos(Pisos) -> receive
	{display,all,M} -> envia_a_tots(Pisos,{display,M}),procPisos(Pisos);
	{display,N,M} -> lists:nth(N+1,Pisos) ! {display,M},procPisos(Pisos);
	{sent_except,display,Message,Except} -> envia_a_tots_excepte(Pisos,display,{display,Message},Except,1),procPisos(Pisos);
	{set_light,Pis,all,on} -> lists:nth(Pis+1,Pisos) ! {light_on,up}, lists:nth(Pis+1,Pisos) ! {light_on,down}, procPisos(Pisos);
	{set_light,Pis,all,off} -> lists:nth(Pis+1,Pisos) ! {light_off,up}, lists:nth(Pis+1,Pisos) ! {light_off,down},procPisos(Pisos);
	{set_light,Pis,N,on} -> lists:nth(Pis+1,Pisos) ! {light_on,N},procPisos(Pisos);
	{set_light,Pis,N,off} -> lists:nth(Pis+1,Pisos) ! {light_off,N},procPisos(Pisos);
	kill -> envia_a_tots(Pisos,kill), killed

end.

create(0) -> [bpis1:new(0)];
create(N) -> create(N-1) ++ [bpis1:new(N)]. 

start(N) -> LlistaPisos=create(N-1),register(bppool,spawn(?MODULE,procPisos,[LlistaPisos])).

 





