%%%-------------------------------------------------------------------
%%% @author Sebas Vila-Marta <sebas@microbi.localnet>
%%% @copyright (C) 2012, Sebas Vila-Marta
%%% @doc
%%% Singleton process that serves current wx environment
%%% @end
%%% Created : 25 Nov 2012 by Sebas Vila-Marta <sebas@microbi.localnet>
%%%-------------------------------------------------------------------
-module(wxenv).

-export([start/0, init/0, get/0, kill/0]).


start() ->
    register(wxenv, spawn(wxenv, init, [])).

get() ->
    wxenv!{get, self()},
    receive
	{wxenv, E} ->
	    E
    end.

kill() ->
    wxenv!kill.

init() ->
    wx:new(),
    E = wx:get_env(),
    loop(E).

loop(E) ->
    receive
	{get, CallerPid} ->
	    CallerPid!{wxenv, E},
	    loop(E);
	kill ->
	    ok;
	_ ->
	    loop(E)
    end.

