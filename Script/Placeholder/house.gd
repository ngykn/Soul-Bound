class_name House2 extends Node2D


@export var interior : ExitDoor
@export var _is_lock : bool = true

@onready var door : Door = $Door
@onready var tilemap = $TileMap

var camera_default_limit := [
		-10000000,
		-10000000,
		10000000,
		10000000
	]

func _ready():
	if !_is_lock:
		GlobalFunction.disable_layer(tilemap,"Door")

func _unhandled_key_input(event) -> void:
	if event.is_action_pressed("interact"):
		if door._can_enter:
			if !_is_lock:
				if interior:
					_enter()
			else:
				GlobalFunction.costumize_show_dialogue(load("res://Dialogue/player.dialogue"),"Door_is_lock")
func _enter() -> void:
	interior.previous_camera_bounds = get_tree().current_scene.camera._get_limit()
	get_tree().current_scene.camera.set_bounds(camera_default_limit)
	TransitionManager.entering_house_transition(interior.global_position)


