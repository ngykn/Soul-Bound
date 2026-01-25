class_name ExitDoor extends Node2D

@export var house_parent : Node2D
@export var position_buffer : Vector2
@onready var door : Door = $Door

var previous_camera_bounds : Array

func _unhandled_key_input(event):
	if event.is_action_pressed("interact") and door._can_enter:
		await TransitionManager.entering_house_transition(house_parent.door.global_position + position_buffer)
		get_tree().current_scene.camera.set_bounds(previous_camera_bounds)
