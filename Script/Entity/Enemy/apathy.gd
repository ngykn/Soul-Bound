class_name Apathy extends CharacterBody2D

@export var orb_scene : PackedScene

@onready var attack_timer = $AttackTimer

var state : String = "idle"
var vulnerable : bool = false

func attack() -> void:
	if vulnerable:
		return

	spawn_orb()

func die() -> void:
	queue_free()

func spawn_orb():
	var current_orb = orb_scene.instantiate()
	current_orb.global_position = global_position
	current_orb.apathy = self
	get_parent().add_child(current_orb)
