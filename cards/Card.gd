class_name Card
extends Area2D

signal selected

export(float) var points := 1.0
export(String) var description

onready var points_lbl := $Sprite/Points
onready var desc_lbl := $Sprite/Description
onready var player_list := $Sprite/PlayerList

onready var anim_player := $AnimationPlayer

var selected := false setget set_selected


func _ready():
	points_lbl.text = str(points)
	desc_lbl.text = description
	player_list.hide()


func set_selected(value: bool) -> void:
	selected = value
	if selected:
		anim_player.play("selected")
	else:
		anim_player.play("idle")


func add_player(name) -> void:
	var label := Label.new()
	label.text = name
	player_list.add_child(label)


func show_players() -> void:
	player_list.show()


func hide_players() -> void:
	player_list.hide()


func reset_players() -> void:
	for p in player_list.get_children():
		p.queue_free()


func _on_Card_mouse_entered():
	if not selected:
		anim_player.play("hover")


func _on_Card_mouse_exited():
	if not selected:
		anim_player.play("idle")


func _on_Card_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		emit_signal("selected")
