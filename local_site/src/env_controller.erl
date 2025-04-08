-module(env_controller).
-behavior(gen_server).

%% Public API:
-export([start_link/0, poll_sensors/0]).

%% Standard gen_server callbacks:
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {sensor_data = #{}}).

%% Start the controller process
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% Externally trigger a poll (this sends a cast message)
poll_sensors() ->
    gen_server:cast(?MODULE, poll).

%% Initialization: schedule the first automatic poll after 5000ms
init([]) ->
    erlang:send_after(5000, self(), poll_sensors),
    {ok, #state{}}.

%% handle_info/2: Poll sensor data when receiving the poll_sensors message
handle_info(poll_sensors, State) ->
    %% Poll the sensors for room1 and room2
    TempRoom1 = gallery_temperature_sensor:read_temperature(room1),
    TempRoom2 = gallery_temperature_sensor:read_temperature(room2),
    HumidityRoom1 = gallery_humidity_sensor:read_humidity(room1),
    HumidityRoom2 = gallery_humidity_sensor:read_humidity(room2),
    
    io:format("Room1: Temperature = ~p°C, Humidity = ~p%%%n", [TempRoom1, HumidityRoom1]),
    io:format("Room2: Temperature = ~p°C, Humidity = ~p%%%n", [TempRoom2, HumidityRoom2]),
    
    %% Update state with the new sensor data:
    NewSensorData = #{
        room1 => #{temperature => TempRoom1, humidity => HumidityRoom1},
        room2 => #{temperature => TempRoom2, humidity => HumidityRoom2}
    },
    erlang:send_after(5000, self(), poll_sensors),
    {noreply, State#state{sensor_data = NewSensorData}}.

%% handle_cast/2: Respond to cast messages.
handle_cast(poll, State) ->
    %% Manually trigger polling by calling the poll_sensors handler
    handle_info(poll_sensors, State);
handle_cast(_Msg, State) ->
    {noreply, State}.

%% handle_call/3: Currently, we respond with ok for any call.
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%% Termination callback
terminate(_Reason, _State) ->
    ok.

%% Code change callback
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
