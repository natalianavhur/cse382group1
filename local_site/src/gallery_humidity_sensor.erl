%% @doc
%% A humidity sensor module that simulates periodic readings for a given room.
%%
%% This module implements a `gen_server` that periodically updates and provides
%% the current humidity value for a specific room. The sensor starts with a base
%% humidity of 45.0% and applies random fluctuations to simulate real-world behavior.
%%
%% @author [Natalia Navarrete]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Module-level complexity is low. Periodic updates use timers and simple arithmetic.
-module(gallery_humidity_sensor).

-behavior(gen_server).

%% Public API:
-export([start_link/1, read_humidity/1]).

%% Standard gen_server callbacks:
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER(RoomId), { ?MODULE, RoomId }).

-record(state, {
    humidity_value = 45.0, %% Initial humidity value in percentage
    room_id :: term()      %% Identifier for the room the sensor is monitoring
}).

%% @doc
%% Starts the humidity sensor process linked to the calling process for a specific room.
%%
%% @spec start_link(RoomId :: term()) -> {ok, Pid} | {error, Reason}
%% @author [author]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Simple wrapper around gen_server:start_link/4.
start_link(RoomId) ->
    gen_server:start_link({local, ?SERVER(RoomId)}, ?MODULE, [RoomId], []).

%% @doc
%% Reads the current humidity value for the given room.
%%
%% @spec read_humidity(RoomId :: term()) -> float()
%% @author [author]
%% @version [version]
%% @since 2025-04-08
%% @doc complexity: Direct gen_server call with constant time response.
read_humidity(RoomId) ->
    gen_server:call(?SERVER(RoomId), read_humidity).

%% @private
%% Initializes the server state and schedules the first sensor reading.
%%
%% @spec init([RoomId :: term()]) -> {ok, State}
%% @doc complexity: Constant time; sets up timer and initial state.
init([RoomId]) ->
    erlang:send_after(1000, self(), read_sensor),
    {ok, #state{room_id = RoomId}}.

%% @private
%% Handles synchronous calls such as reading humidity.
%%
%% @spec handle_call(Request, From, State) -> {reply, Reply, State}
%% @doc complexity: Pattern match and simple value retrieval; constant time.
handle_call(read_humidity, _From, State = #state{humidity_value = Value}) ->
    {reply, Value, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%% @private
%% Handles asynchronous messages (none defined for now).
%%
%% @spec handle_cast(Msg, State) -> {noreply, State}
%% @doc complexity: Constant time default handler.
handle_cast(_Msg, State) ->
    {noreply, State}.

%% @private
%% Handles internal messages like the periodic sensor update.
%%
%% @spec handle_info(Msg, State) -> {noreply, State}
%% @doc complexity: Low complexity; generates random fluctuation and updates state.
handle_info(read_sensor, State) ->
    BaseHumidity = 45.0,
    MaxFluctuation = 15.0,
    RandomFluctuation = (rand:uniform() * MaxFluctuation) - (MaxFluctuation / 2),
    NewValue = BaseHumidity + RandomFluctuation,
    NewState = State#state{humidity_value = NewValue},
    erlang:send_after(1000, self(), read_sensor),
    {noreply, NewState};
handle_info(_Info, State) ->
    {noreply, State}.

%% @private
%% Handles termination of the gen_server.
%%
%% @spec terminate(Reason, State) -> ok
%% @doc complexity: Constant time.
terminate(_Reason, _State) ->
    ok.

%% @private
%% Handles code upgrades.
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, State}
%% @doc complexity: Constant time; no transformation applied.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.