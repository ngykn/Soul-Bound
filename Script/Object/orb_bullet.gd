extends CharacterBody2D

@export var speed := 260.0
@export var lifetime := 3.0

var direction := Vector2.ZERO

func _ready() -> void:
	velocity = direction.normalized() * speed
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta) -> void:
	move_and_slide()

	if get_slide_collision_count() > 0:
		queue_free()
