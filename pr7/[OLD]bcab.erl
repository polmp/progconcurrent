% Paràmetres: 
%	N Nombre de botons
% 	P Procés al que ha d'enviar els missatges

-module(bcab).
-compile(export_all).
-include_lib("wx/include/wx.hrl").

-define(BUTTON_ID_OPEN,  200).
-define(BUTTON_ID_CLOSE, 201).


new(N,P) ->
    wx:new(),
    Env=wx:get_env(),
    spawn(?MODULE, bcab_proc, [N,P,Env]).

bcab_proc(N,P,Env) ->
    wx:set_env(Env),
    Frame = create_window(N),
    L = crearBotonera(Frame,N),
    loop(Frame, L, P, N),
    ok.

create_window(N) ->
    Frame = wxFrame:new(wx:null(), -1, "Botonera", 
				[{size, {120, 150+N*30}},
				{style, ?wxRESIZE_BORDER bor ?wxSYSTEM_MENU 
					bor ?wxCAPTION bor ?wxCLOSE_BOX 
					bor ?wxCLIP_CHILDREN}]), % window title
    wxFrame:connect(Frame, close_window),
    Frame.

crearBotonera(Frame, N) ->
	Panel = wxPanel:new(Frame),
	
    % Create display ans add to sizer
    Display = wxTextCtrl:new(Panel, 100, 
			     [{style,?wxTE_READONLY bor ?wxTE_CENTRE},
				 {pos,{10,10}}, {size, {100,22}}, {value, "0"}]),
    Redtext = wxTextAttr:new({255,10,10}),
    wxTextCtrl:setDefaultStyle(Display, Redtext),
 
	LlistaBotons = crearBotons(Panel, N-1, 0),

	% Crear els botons d'obrir i tancar les portes
    OpenB = wxButton:new(Panel, ?BUTTON_ID_OPEN, [{label,"< >"},{pos,{10,50+N*30}},{size, {100,22}}]),
    wxButton:setToolTip(OpenB, "Obre portes"),
    CloseB = wxButton:new(Panel, ?BUTTON_ID_CLOSE, [{label,"> <"},{pos,{10,80+N*30}},{size, {100,22}}]),
    wxButton:setToolTip(CloseB, "Tanca portes"),
	
	wxPanel:connect(Panel, command_button_clicked),
	wxFrame:show(Frame),
	{LlistaBotons, Display}.

  
crearBotons(Panel, 0, Pos ) -> 
    Btip   = io_lib:format("Planta ~B",[0]),
	Boto = wxButton:new(Panel, 0, [{label, Btip}, {pos,{10,50+Pos*30}},{size, {100,22}}]),
	wxButton:setBackgroundColour(Boto,{246,246,245}),
	[Boto|[]];

crearBotons(Panel, N, Pos) ->
    Btip   = io_lib:format("Planta ~B",[N]),
	Boto = wxButton:new(Panel, N, [{label, Btip}, {pos,{10,50+Pos*30}},{size, {100,22}}]),
	wxButton:setBackgroundColour(Boto,{246,246,245}),
	[Boto|crearBotons(Panel, N-1, Pos+1)].
	
loop(Frame, W, P, N) ->
    {ButtonLst,Display} = W,
   receive 
   	#wx{event=#wxClose{}} ->
   	    io:format("~p Closing window ~n",[self()]),
	    wxWindow:destroy(Frame),
	    P!abort,
	    ok;
   	#wx{id=?BUTTON_ID_OPEN,
	    event=#wxCommand{type=command_button_clicked}} ->
	    P!open_doors,
	    loop(Frame, W, P, N);
   	#wx{id=?BUTTON_ID_CLOSE,
	    event=#wxCommand{type=command_button_clicked}} ->
	    P!close_doors,
	    loop(Frame, W, P, N);
   	#wx{id=Id,event=#wxCommand{type=command_button_clicked}} ->
	    P!{clicked,Id},
		io:format("Botó premut ~p~n",[Id]),
	    loop(Frame, W, P, N);
 	kill -> 
	    wxWindow:destroy(Frame),
	    ok;
	{light_on, F} when F<N, F>=0 ->
	    B = lists:nth(length(ButtonLst)-F,ButtonLst),
		%io:format("Encent boto ~p, ~p~n",[F,B]),
	    wxButton:setBackgroundColour(B,{255,255,153}),
	    loop(Frame, W, P, N);
	{light_off, F} when F<N, F>=0 ->
	    B = lists:nth(length(ButtonLst)-F,ButtonLst),
	    wxButton:setBackgroundColour(B,{246,246,245}), % nullColour
	    loop(Frame, W, P, N);
	{display, V} when is_integer(V) ->
	    % show V in the display
	    T = io_lib:format("~B",[V]),
	    wxTextCtrl:clear(Display),
	    wxTextCtrl:setValue(Display,T),
	    loop(Frame, W, P, N);
	{display, L} when is_list(L) ->
	    % show V in the display
	    T = io_lib:format("~10s",[L]),
	    wxTextCtrl:clear(Display),
	    wxTextCtrl:setValue(Display,T),
	    loop(Frame, W, P, N);
	Msg ->
	    io:format("Botonera missatge desconegut ~p ~n", [Msg]),
	    loop(Frame, W, P, N)
    end.


 
