-module(bcab).
-compile(export_all).
-define(PORTARD,"/dev/ttyACM0").

loop(P,Port) -> receive
	{Port,{data,"OP\n"}} -> P!open_doors, loop(P,Port);
	{Port,{data,"TP\n"}} -> P!close_doors, loop(P,Port);
	{Port,{data,"B0\n"}} -> io:format("CLICO ~p~n",[0]),P!{clicked,0}, loop(P,Port);
	{Port,{data,"B1\n"}} -> io:format("CLICO ~p~n",[1]),P!{clicked,1}, loop(P,Port);
	{Port,{data,"B2\n"}} -> io:format("CLICO ~p~n",[2]),P!{clicked,2}, loop(P,Port);
	{Port,{data,"B3\n"}} -> P!{clicked,3}, loop(P,Port);
	{Port,{data,"B4\n"}} -> P!{clicked,4}, loop(P,Port);
	{Port,{data,"B5\n"}} -> P!{clicked,5}, loop(P,Port);
	{light_on,N} when N>=0,N<6 -> port_command(Port,"E"++integer_to_list(N)),loop(P,Port);
	{light_off,N} when N>=0,N<6 -> port_command(Port,"A"++integer_to_list(N)),loop(P,Port);
	{display,V} when V>=0,V<6 -> port_command(Port,"D"++integer_to_list(V)),loop(P,Port);
	{Port,{data,_}} -> loop(P,Port);
	_ -> loop(P,Port)
end.

new(P) -> Port=open_port(?PORTARD,[]),Pid=spawn(?MODULE,loop,[P,Port]),port_connect(Port, Pid),Pid.
