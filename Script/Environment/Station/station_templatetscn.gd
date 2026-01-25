class_name Station extends StaticBody2D

@export var npc : NPC

var _is_operating : bool = true

func _ready() -> void:
	await get_tree().process_frame
	if !npc:
		return
	
	npc._return_to_original_direction = false
	npc.face_direction(global_position)
	npc.dialogue_started.connect(_station_stop_operation)
	npc.dialogue_ended.connect(_station_operating)


func _station_operating() -> void:
	if _is_operating:
		return

	_is_operating = true
	npc.face_direction(global_position)

func _station_stop_operation() -> void:
	_is_operating = false
