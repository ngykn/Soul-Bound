extends Area2D

@export var speed := 120.0
@export var reveal_distance := 120.0
@export var full_visible_distance := 50.0

var direction := Vector2.ZERO
@onready var player := get_tree().get_first_node_in_group("player")

func _process(delta):
	global_position += direction * speed * delta

	if not player:
		return

	var dist := global_position.distance_to(player.global_position)

	# alpha control
	if dist > reveal_distance:
		modulate.a = 0.0
	elif dist <= full_visible_distance:
		modulate.a = 1.0
	else:
		modulate.a = remap(
			dist,
			reveal_distance,
			full_visible_distance,
			0.0,
			1.0
		)
