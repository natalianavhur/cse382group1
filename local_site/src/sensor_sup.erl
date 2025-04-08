-module(sensor_sup).
-behavior(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

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
    %% one_for_one strategy: if one sensor crashes, only that one is restarted
    {ok, {{one_for_one, 5, 10}, Children}}.
