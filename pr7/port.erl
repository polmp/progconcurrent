-module(port).
-export([start_port/0,portProcess/0]).
-define(PORTARD,"/dev/ttyACM0").

portProcess() -> receive
	{Port,{data,"B0\n"}} -> port_command(Port,"E0"), portProcess();
	{Port,{data,Data}} -> portProcess();
	{'EXIT',Port,Reason} -> ok;
	_ -> portProcess()
end.

start_port() -> Port=open_port(?PORTARD,[]),Pid=spawn(?MODULE,portProcess,[self()]),port_connect(Port, Pid).
