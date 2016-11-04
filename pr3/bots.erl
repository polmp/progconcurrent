% Paràmetres: 
%	N Nombre de botons
% 	P Procés al que ha d'enviar els missatges

-module(bots).
-compile(export_all).
-include_lib("wx/include/wx.hrl").

nou(N, P) ->
    spawn(?MODULE, crearBotonera, [N, P]).


crearBotonera(N, P) ->
	wx:new(),
	Frame = wxFrame:new(wx:null(), ?wxID_ANY, "Botonera", [{size, {120, N*30+50}}]),
	Panel = wxPanel:new(Frame),
	LlistaBotons = crearBotons(Panel, N-1, 0),
	wxPanel:connect(Panel, command_button_clicked),
	wxFrame:connect(Frame, close_window),
	wxFrame:show(Frame),
    loop(Panel, LlistaBotons, P, N).

  
crearBotons(Panel, 0, Pos ) -> 
    Btip   = io_lib:format("Planta ~B",[0]),
	Boto = wxButton:new(Panel, 0, [{label, Btip}, {pos,{10,10+Pos*30}},{size, {100,22}}]),
	[Boto|[]];

crearBotons(Panel, N, Pos) ->
    Btip   = io_lib:format("Planta ~B",[N]),
	Boto = wxButton:new(Panel, N, [{label, Btip}, {pos,{10,10+Pos*30}},{size, {100,22}}]),
	wxButton:setBackgroundColour(Boto,{246,246,245}),
	[Boto|crearBotons(Panel, N-1, Pos+1)].
	
  
loop(Panel, Botons, P, N) ->
	receive
		#wx{event = #wxClose{}} ->
			io:format("~p Closing window ~n",[self()]),
			wxWindow:destroy(Panel),
			P!abort,
			ok;

		#wx{id = Id,event = #wxCommand{type = command_button_clicked}} ->
			%io:format("Boto premut ~p~n", [Id]),
			P!{clicked,Id},
			loop(Panel, Botons, P, N);

		close -> 
			wxWindow:destroy(Panel),
			P!abort,
			ok;
			
		{light_on, F} when F < N , F >= 0 ->
			B = lists:nth(length(Botons)-F,Botons),
			%io:format("Boto ~p~n",[length(Botons)-F]),
			wxButton:setBackgroundColour(B,{255,255,153}),
			loop(Panel, Botons, P, N);

		{light_on, F} when F >= N ->
			io:format("El boto ~p no existeix~n",[F]),
			loop(Panel, Botons, P, N);

		{light_off, F} when F < N , F >= 0 -> 
			B = lists:nth(length(Botons)-F,Botons),
			wxButton:setBackgroundColour(B,{246,246,245}), % nullColour
			loop(Panel, Botons, P, N);

		{light_off, F} when F >= N -> 
			io:format("El boto ~p no existeix~n",[F]),
			loop(Panel, Botons, P, N);
			
			
		Msg ->
			io:format("Botonera missatge desconegut ~p ~n", [Msg]),
			loop(Panel, Botons, P, N)

  end.