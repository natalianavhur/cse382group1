%%%-------------------------------------------------------------------
%% @doc local_site public API
%% @end
%%%-------------------------------------------------------------------

-module(local_site_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    SupervisorSpec = {local_site_sup, {local_site_sup, start_link, []},
                        permanent, 2000, supervisor, [local_site_sup]},
    {ok, Pid} = supervisor:start_link(SupervisorSpec),
    {ok, Pid}.

stop(_State) ->
    ok.

%% internal functions
