-module(port).
-export([start_port/0,portProcess/1]).
-define(PORTARD,"/dev/tty.usbmodem1411").

portProcess(Port) -> receive
  {Port,{data,Data}} -> ok
end.

start_port() -> Port=open_port(?PORTARD,[]),Pid=spawn(?MODULE,portProcess,[Port]),port_connect(Port, Pid).
