%% @doc
%% A temperature sensor module that simulates real-time temperature readings for a given room.
%%
%% This module implements a `gen_server` process for each room, simulating indoor
%% temperature based on time-of-day logic. During the day (10:00 to 17:59), the base
%% temperature is set higher, with fluctuations added to simulate realistic behavior.
%%
%% @author [Natalia Navarrete]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Module-level complexity is low. Time-based temperature simulation uses basic control flow and random number generation.
-module(gallery_temperature_sensor).

-behavior(gen_server).

%% Public API:
-export([start_link/1, read_temperature/1]).

%% Standard gen_server callbacks:
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER(RoomId), { ?MODULE, RoomId }).

-record(state, {
    temperature_value = 20.0, %% Default starting temperature in Celsius
    room_id :: term()         %% Identifier for the room
}).

%% @doc
%% Starts the temperature sensor process for the specified room.
%%
%% @spec start_link(RoomId :: term()) -> {ok, Pid} | {error, Reason}
%% @author [author]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Simple process startup using gen_server:start_link/4.
start_link(RoomId) ->
    gen_server:start_link({local, ?SERVER(RoomId)}, ?MODULE, [RoomId], []).

%% @doc
%% Returns the current temperature value for the given room.
%%
%% @spec read_temperature(RoomId :: term()) -> float()
%% @author [author]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Constant-time synchronous call.
read_temperature(RoomId) ->
    gen_server:call(?SERVER(RoomId), read_temperature).

%% @private
%% Initializes the server with the room ID and starts the periodic sensor update.
%%
%% @spec init([RoomId :: term()]) -> {ok, State}
%% @doc complexity: Constant time; sets up state and schedules first update.
init([RoomId]) ->
    erlang:send_after(1000, self(), read_sensor),
    {ok, #state{room_id = RoomId}}.

%% @private
%% Handles synchronous requests such as reading the temperature value.
%%
%% @spec handle_call(Request, From, State) -> {reply, Reply, State}
%% @doc complexity: Constant time for pattern-matched known calls.
handle_call(read_temperature, _From, State = #state{temperature_value = Value}) ->
    {reply, Value, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%% @private
%% Handles asynchronous cast messages (not used in this module).
%%
%% @spec handle_cast(Msg, State) -> {noreply, State}
%% @doc complexity: Constant time default handler.
handle_cast(_Msg, State) ->
    {noreply, State}.

%% @private
%% Periodically updates the temperature based on time of day with random fluctuation.
%%
%% @spec handle_info(Msg, State) -> {noreply, State}
%% @doc complexity: Moderate. Uses pattern matching on time, random number generation, and state updates.
handle_info(read_sensor, State) ->
    Now = calendar:local_time(),
    BaseTemp = case Now of
                   {{_Year, _Month, _Day}, {Hour, _Min, _Sec}} when Hour >= 10, Hour < 18 ->
                       22.0;
                   _ ->
                       20.0
               end,
    MaxFluctuation = 3.0,
    RandomFluctuation = (rand:uniform() * MaxFluctuation) - (MaxFluctuation / 2),
    NewValue = BaseTemp + RandomFluctuation,
    NewState = State#state{temperature_value = NewValue},
    erlang:send_after(1000, self(), read_sensor),
    {noreply, NewState};
handle_info(_Info, State) ->
    {noreply, State}.

%% @private
%% Cleans up when the gen_server is terminating.
%%
%% @spec terminate(Reason, State) -> ok
%% @doc complexity: Constant time.
terminate(_Reason, _State) ->
    ok.

%% @private
%% Handles hot code upgrades (no-op in this case).
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, State}
%% @doc complexity: Constant time pass-through.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
