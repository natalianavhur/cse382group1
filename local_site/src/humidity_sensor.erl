-module(humidity_sensor).
-behavior(gen_server).

%% Public API:
-export([start_link/1, read_humidity/1]).  % room id required

%% Standard gen_server callbacks:
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER(RoomId), { ?MODULE, RoomId }).

-record(state, {humidity_value = 45.0, room_id :: term()}).

start_link(RoomId) ->
    gen_server:start_link({local, ?SERVER(RoomId)}, ?MODULE, [RoomId], []).

read_humidity(RoomId) ->
    gen_server:call(?SERVER(RoomId), read_humidity).

init([RoomId]) ->
    erlang:send_after(1000, self(), read_sensor),
    {ok, #state{room_id = RoomId}}.

handle_call(read_humidity, _From, State = #state{humidity_value = Value}) ->
    {reply, Value, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(read_sensor, State) ->
    BaseHumidity = 45.0,
    MaxFluctuation = 15.0,
    %% Generate fluctuation so that the humidity is roughly in 30-60% range:
    RandomFluctuation = (rand:uniform() * MaxFluctuation) - (MaxFluctuation / 2),
    NewValue = BaseHumidity + RandomFluctuation,
    NewState = State#state{humidity_value = NewValue},
    erlang:send_after(1000, self(), read_sensor),
    {noreply, NewState};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
