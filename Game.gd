extends Node2D

onready var start_btn := $UI/Control/StartButton
onready var cards_list := $Cards.get_children()
onready var countdown_lbl := $UI/Control/CountdownLabel
onready var play_timer := $PlayTimer
onready var player_list := $UI/Control/PlayerList
onready var session_lbl := $UI/Control/Label/SessionLabel

var my_points := 0.0

var in_progress := false


func _ready():
	$UI/Control/StartButton.hide()
	Server.connect("new_player", self, "_on_new_player")
	Server.connect("player_left", self, "_on_player_left")
	Server.connect("received_points", self, "_on_received_points")
	Server.connect("show_player_points", self, "_on_show_points")
	Server.connect("start_timer", self, "_on_start_timer")
	Server.connect("end_timer", self, "_on_end_timer")
	if Server.is_host:
		_update_host_ui()
	
	for card in cards_list:
		card.connect("selected", self, "_select_card", [card])
	
	for p in Server.players:
		_add_player_to_list(p, Server.players[p])
	
	
	session_lbl.text = Server.session_name


func _process(_delta):
	countdown_lbl.text = str(int(play_timer.time_left))


func _on_received_points(id: int, points: int) -> void:
	print("%d sent %d points" % [id, points])
	var player_name: String = Server.players[id]['name']
	for c in cards_list:
		if c.points == points:
			c.add_player(player_name)


func _on_show_points() -> void:
	print("showing points")
	for c in cards_list:
		c.show_players()


func _on_start_timer():
	in_progress = true
	play_timer.start()
	for c in cards_list:
		c.set_selected(false)
		c.reset_players()
		c.hide_players()


func _on_end_timer():
	in_progress = false
	play_timer.stop()


func _select_card(card: Card) -> void:
	for c in cards_list:
		c.set_selected(false)
	card.set_selected(true)
	my_points = card.points
	Server.rpc_id(1, "send_points", my_points)


func _update_host_ui() -> void:
	$UI/Control/StartButton.show()


func _add_player_to_list(id, info) -> void:
	var lbl := Label.new()
	lbl.text = info['name']
	lbl.name = str(id)
	player_list.add_child(lbl)


func _on_new_player(id, info) -> void:
	_add_player_to_list(id, info)


func _on_player_left(id: int) -> void:
	for p in player_list.get_children():
		if int(p.name) == id:
			p.queue_free()


func _on_StartButton_pressed():
	start_btn.disabled = true
	_on_start_timer()
	Server.rpc_id(1, "start_timer")


func _on_PlayTimer_timeout():
	in_progress = false
	start_btn.disabled = false
	if Server.is_host:
		_on_show_points()
		Server.rpc_id(1, "end_timer")
		Server.rpc_id(1, "show_points")
