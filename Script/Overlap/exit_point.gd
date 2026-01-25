class_name ChunkExit extends Area2D

@export_category("Path")
@export var next_chunk : String
@export var entry_point : String

@export_category("Collision")
@export var collision_disabled : bool = false

@onready var collision = $CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_collision_disabled(collision_disabled)


func set_collision_disabled(b: bool) -> void:
	collision.set_deferred("disabled", b)


func _on_body_entered(body) -> void:
	if !next_chunk:
		return

	if body.is_in_group("player"):
		TransitionManager.go_to_chunk(get_tree().current_scene, next_chunk,entry_point)
