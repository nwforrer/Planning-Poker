extends Control

onready var name_text := $VBoxContainer/HBoxContainer/NameText
onready var join_btn := $VBoxContainer/HBoxContainer2/JoinButton
onready var host_btn := $VBoxContainer/HostButton
onready var session_txt := $VBoxContainer/HBoxContainer2/SessionName

var hosting := false

var peer: WebSocketClient = null


func _ready():
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	
	if OS.has_environment("USERNAME"):
		name_text.text = OS.get_environment("USERNAME")


func _on_peer_connected(id: int):
	print("%d connected" % id)


func _on_peer_disconnected(id: int):
	print("%d disconnected" % id)


func _on_connected_to_server():
	print("connection succeeded")
	join_btn.disabled = false
	host_btn.disabled = false
	if hosting:
		Server.request_create_session()
	else:
		Server.request_join_session(session_txt.text)


func _on_connection_failed():
	join_btn.disabled = false
	get_tree().set_network_peer(null)
	peer = null
	print("connection failed")


func _on_HostCheckBox_toggled(button_pressed):
	Server.is_host = button_pressed


func _on_HostButton_pressed():
	Server.my_info['name'] = name_text.text
	hosting = true
	
	peer = WebSocketClient.new()
	peer.connect_to_url("ws://localhost:5555", PoolStringArray(["ludus"]), true)
	get_tree().set_network_peer(peer)


func _on_JoinButton_pressed():
	Server.my_info['name'] = name_text.text
	hosting = false
	
	peer = WebSocketClient.new()
	peer.connect_to_url("ws://localhost:5555", PoolStringArray(["ludus"]), true)
	get_tree().set_network_peer(peer)
