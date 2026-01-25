extends Area2D

signal entered

@export var point : SceneEntryPoint

var _in_area : bool = false

func _ready():
	set_deferred("collision_mask",2)
	body_entered.connect(_on_body_entered.bind(true))
	body_exited.connect(_on_body_entered.bind(false))

func _unhandled_key_input(event):
	if event.is_action_pressed("interact"):
		if _in_area:
			TransitionManager.cave_entry_transition(point)

func _on_body_entered(body, value : bool) -> void:
	if !body.is_in_group("player"):
		return
		
	_in_area = value
