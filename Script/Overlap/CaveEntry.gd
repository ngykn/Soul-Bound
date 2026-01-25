class_name CaveEntry extends Area2D

signal entered

@export var to_cave_chunk : String
@export var exit_point : String

var _can_enter := false

func _ready():
	body_entered.connect(_on_body_entered.bind(true))
	body_exited.connect(_on_body_entered.bind(false))
	
	set_deferred("monitorable",false)
	set_deferred("collision_mask",2)
	
func _unhandled_key_input(event):
	if _can_enter:
		if event.is_action_pressed("interact"):
			TransitionManager.go_to_chunk(self, to_cave_chunk,exit_point)
			emit_signal("area_entered")
	
func _on_body_entered(body, value : bool) -> void:
	if !body.is_in_group("player"):
		return
		
	_can_enter = value
