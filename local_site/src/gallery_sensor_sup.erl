%% @doc
%% Supervisor for temperature and humidity sensors in a gallery setting.
%%
%% This module supervises sensor processes for two rooms, `room1` and `room2`,
%% managing both temperature and humidity sensors. Each sensor is started and
%% monitored under a `one_for_one` strategy, ensuring isolated restarts in case of failures.
%%
%% @author [Natalia Navarrete]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Module-level complexity is low. Defines and supervises children with static configuration.
-module(gallery_sensor_sup).

-behavior(supervisor).

-export([start_link/0]).
-export([init/1]).

%% @doc
%% Starts the sensor supervisor.
%%
%% @spec start_link() -> {ok, Pid} | {error, Reason}
%% @author [author]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Very low; simple wrapper around `supervisor:start_link/3`.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @private
%% Initializes the supervisor with child specs for temperature and humidity sensors
%% for `room1` and `room2`, using a `one_for_one` strategy.
%%
%% @spec init([]) -> {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}.
%% @doc complexity: Low. Static setup of child specifications and supervision strategy.
init([]) ->
    %% Define children for two rooms: room1 and room2
    TemperatureSensorRoom1 = {
        {gallery_temperature_sensor, room1},
        {gallery_temperature_sensor, start_link, [room1]},
        permanent,
        5000,
        worker,
        [gallery_temperature_sensor]
    },
    TemperatureSensorRoom2 = {
        {gallery_temperature_sensor, room2},
        {gallery_temperature_sensor, start_link, [room2]},
        permanent,
        5000,
        worker,
        [gallery_temperature_sensor]
    },
    HumiditySensorRoom1 = {
        {gallery_humidity_sensor, room1},
        {gallery_humidity_sensor, start_link, [room1]},
        permanent,
        5000,
        worker,
        [gallery_humidity_sensor]
    },
    HumiditySensorRoom2 = {
        {gallery_humidity_sensor, room2},
        {gallery_humidity_sensor, start_link, [room2]},
        permanent,
        5000,
        worker,
        [gallery_humidity_sensor]
    },
    Children = [
        TemperatureSensorRoom1,
        TemperatureSensorRoom2,
        HumiditySensorRoom1,
        HumiditySensorRoom2
    ],
    %% one_for_one strategy: if one sensor crashes, only that sensor is restarted
    {ok, {{one_for_one, 5, 10}, Children}}.
