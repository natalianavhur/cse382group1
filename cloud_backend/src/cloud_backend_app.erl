%%%-------------------------------------------------------------------
%% @doc cloud_backend public API
%% @end
%%%-------------------------------------------------------------------

-module(cloud_backend_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    SupervisorSpec = {cloud_backend_sup, {cloud_backend_sup, start_link, []},
                        permanent, 2000, supervisor, [cloud_backend_sup]},
    {ok, Pid} = supervisor:start_link(SupervisorSpec),
    {ok, Pid}.

stop(_State) ->
    ok.

%% internal functions
