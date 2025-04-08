%%%-------------------------------------------------------------------
%% @doc local_site top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(local_site_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

% -define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    %% Child #1: The sensor supervisor
    SensorSup = {sensor_sup,
                 {sensor_sup, start_link, []},
                 permanent,
                 5000,
                 supervisor,
                 [sensor_sup]},

    %% Here you could define other children like:
    %%   hvac_controller, local_alerts, mqtt_publisher, etc.

    %% For example (placeholder):
    %% HvacController = {hvac_controller, {hvac_controller, start_link, []},
    %%                   permanent, 5000, worker, [hvac_controller]},
    Children = [
        SensorSup
        %% , HvacController, ...
    ],

    %% We choose a one_for_one strategy so that if one child process
    %% fails, only that process is restarted.
    {ok, {{one_for_one, 5, 10}, Children}}.

%% internal functions
