-module(alert).
-export([
    send_sms_alert/1,
    local_alert/1,
    cloud_alert/1,
    check_local_conditions/2,
    check_cloud_conditions/2,
    test_local_alert/0,
    test_cloud_alert/0
]).

send_sms_alert(Message) ->
    io:format("Simulated SMS alert: ~s~n", [Message]),
    ok.


local_alert(Message) ->
    io:format("Local alert triggered: ~s~n", [Message]),
    ok.


cloud_alert(Message) ->
    send_sms_alert(Message).


check_local_conditions(SensorReading, Threshold) when SensorReading > Threshold ->
    Message = io_lib:format("Warning: Local sensor reading ~p exceeds threshold ~p", [SensorReading, Threshold]),
    local_alert(lists:flatten(Message));
check_local_conditions(_, _) ->
    ok.


check_cloud_conditions(SensorReading, Threshold) when SensorReading > Threshold ->
    Message = io_lib:format("Alert: Cloud sensor reading ~p exceeds threshold ~p", [SensorReading, Threshold]),
    cloud_alert(lists:flatten(Message));
check_cloud_conditions(_, _) ->
    ok.


test_local_alert() ->
    io:format("Testing local alert with sensor reading 30 and threshold 25~n"),
    check_local_conditions(30, 25).


test_cloud_alert() ->
    io:format("Testing cloud alert with sensor reading 35 and threshold 30~n"),
    check_cloud_conditions(35, 30).
