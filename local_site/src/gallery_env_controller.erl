%% @doc
%% The environment controller module for orchestrating temperature and humidity readings.
%%
%% This `gen_server`-based module acts as a central controller that periodically polls
%% temperature and humidity sensors for multiple rooms. It stores the latest readings
%% and logs them to the console. Manual polling can also be triggered externally.
%%
%% It expects `gallery_temperature_sensor` and `gallery_humidity_sensor` modules to expose
%% `read_temperature/1` and `read_humidity/1` respectively.
%%
%% @author [Natalia Navarrete]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Module-level complexity is moderate. It involves inter-process messaging, scheduled polling, and map-based state updates.
-module(gallery_env_controller).

-behavior(gen_server).

%% Public API:
-export([start_link/0, poll_sensors/0]).

%% Standard gen_server callbacks:
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {
    sensor_data = #{} %% Latest sensor data keyed by room
}).

%% @doc
%% Starts the environment controller process.
%%
%% @spec start_link() -> {ok, Pid} | {error, Reason}
%% @author [author]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Simple wrapper around gen_server:start_link/4.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @doc
%% Manually triggers a poll of the sensors.
%%
%% @spec poll_sensors() -> ok
%% @author [author]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Very low; sends a cast message to self.
poll_sensors() ->
    gen_server:cast(?MODULE, poll).

%% @private
%% Initializes the controller and schedules the first automatic sensor poll.
%%
%% @spec init([]) -> {ok, State}
%% @doc complexity: Constant time; schedules delayed message and initializes state.
init([]) ->
    erlang:send_after(5000, self(), poll_sensors),
    {ok, #state{}}.

%% @private
%% Handles scheduled sensor polling. Reads temperature and humidity from both rooms,
%% prints the results, and updates the state.
%%
%% @spec handle_info(Msg, State) -> {noreply, State}
%% @doc complexity: Moderate. Calls external modules, formats output, and updates nested maps.
handle_info(poll_sensors, State) ->
    TempRoom1 = gallery_temperature_sensor:read_temperature(room1),
    TempRoom2 = gallery_temperature_sensor:read_temperature(room2),
    HumidityRoom1 = gallery_humidity_sensor:read_humidity(room1),
    HumidityRoom2 = gallery_humidity_sensor:read_humidity(room2),

    io:format("Room1: Temperature = ~p°C, Humidity = ~p%%%n", [TempRoom1, HumidityRoom1]),
    io:format("Room2: Temperature = ~p°C, Humidity = ~p%%%n", [TempRoom2, HumidityRoom2]),

    NewSensorData = #{
        room1 => #{temperature => TempRoom1, humidity => HumidityRoom1},
        room2 => #{temperature => TempRoom2, humidity => HumidityRoom2}
    },
    erlang:send_after(5000, self(), poll_sensors),
    {noreply, State#state{sensor_data = NewSensorData}}.

%% @private
%% Handles manual polling triggered via cast.
%%
%% @spec handle_cast(Msg, State) -> {noreply, State}
%% @doc complexity: Very low; defers to `handle_info/2` for actual polling.
handle_cast(poll, State) ->
    handle_info(poll_sensors, State);
handle_cast(_Msg, State) ->
    {noreply, State}.

%% @private
%% Default response to any synchronous call.
%%
%% @spec handle_call(Request, From, State) -> {reply, Reply, State}
%% @doc complexity: Constant time response.
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%% @private
%% Handles termination of the process.
%%
%% @spec terminate(Reason, State) -> ok
%% @doc complexity: Constant time no-op.
terminate(_Reason, _State) ->
    ok.

%% @private
%% Handles hot code upgrade by returning current state as-is.
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, State}
%% @doc complexity: Constant time; no transformation logic.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
