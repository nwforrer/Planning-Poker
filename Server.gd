extends Node

signal new_player(id, info)
signal player_left(id)
signal received_points(id, points)
signal show_player_points
signal start_timer
signal end_timer

var players := {}
var my_info := {}
var session_name: String
var is_host := false


func request_create_session():
	print("request_create_session")
	rpc_id(1, "create_session")


remote func respond_create_session(_session_name: String):
	var id := get_tree().get_rpc_sender_id()
	assert(id == 1)
	print("got session %s" % _session_name)
	session_name = _session_name
	is_host = true
	get_tree().change_scene("res://Game.tscn")


func request_join_session(_session_name: String):
	session_name = _session_name
	rpc_id(1, "join_session", _session_name)


remote func respond_join_session():
	var id := get_tree().get_rpc_sender_id()
	assert(id == 1)
	print("joined session")
	is_host = false
	get_tree().change_scene("res://Game.tscn")


remote func send_info(other_id: int):
	rpc_id(other_id, "register_player", my_info)


remote func register_player(info):
	var id := get_tree().get_rpc_sender_id()
	if not id in players:
		players[id] = info
		emit_signal("new_player", id, info)
		print("updated players info", players)


remote func player_disconnected(id: int):
	players.erase(id)
	emit_signal("player_left", id)


remote func assign_host() -> void:
	is_host = true
	emit_signal("assigned_host")


remote func send_points(id: int, points: int):
	var sender_id := get_tree().get_rpc_sender_id()
	assert(sender_id == 1)
	emit_signal("received_points", id, points)


remote func show_points():
	var sender_id := get_tree().get_rpc_sender_id()
	assert(sender_id == 1)
	emit_signal("show_player_points")


remote func start_timer():
	var sender_id := get_tree().get_rpc_sender_id()
	assert(sender_id == 1)
	emit_signal("start_timer")


remote func end_timer():
	var sender_id := get_tree().get_rpc_sender_id()
	assert(sender_id == 1)
	emit_signal("end_timer")
