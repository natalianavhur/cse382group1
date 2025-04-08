-module(temperature_sensor).
-behavior(gen_server).

%% Public API:
-export([start_link/1, read_temperature/1]).  % room id is required

%% Standard gen_server callbacks:
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER(RoomId), { ?MODULE, RoomId }).

-record(state, {temperature_value = 20.0, room_id :: term()}).

%% start_link/1: Expects a RoomId (e.g., room1 or room2)
start_link(RoomId) ->
    gen_server:start_link({local, ?SERVER(RoomId)}, ?MODULE, [RoomId], []).

%% read_temperature/1: Reads the temperature for the given room
read_temperature(RoomId) ->
    gen_server:call(?SERVER(RoomId), read_temperature).

init([RoomId]) ->
    %% Schedule the first sensor reading after 1000ms
    erlang:send_after(1000, self(), read_sensor),
    {ok, #state{room_id = RoomId}}.

handle_call(read_temperature, _From, State = #state{temperature_value = Value}) ->
    {reply, Value, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(read_sensor, State) ->
    %% Use time-of-day domain-specific logic:
    Now = calendar:local_time(),
    BaseTemp = case Now of
                   {{_Year, _Month, _Day}, {Hour, _Min, _Sec}} when Hour >= 10, Hour < 18 ->
                       22.0;  %% Higher during opening hours
                   _ ->
                       20.0
               end,
    MaxFluctuation = 3.0,
    RandomFluctuation = (rand:uniform() * MaxFluctuation) - (MaxFluctuation / 2),
    NewValue = BaseTemp + RandomFluctuation,
    NewState = State#state{temperature_value = NewValue},
    %% Schedule the next reading:
    erlang:send_after(1000, self(), read_sensor),
    {noreply, NewState};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
