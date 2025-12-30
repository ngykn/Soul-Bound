extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $"../Sprite2D"

var animation_prefix := "idle"
var direction_prefix := "down"

const DEADZONE := 5.0

func change_animation(velocity: Vector2):
	# Idle check
	if velocity.length() < DEADZONE:
		animation_prefix = "idle"
		animation_player.play("%s_%s" % [animation_prefix, direction_prefix])
		return

	animation_prefix = "run"

	# Snap diagonal to 4 directions using dominant axis
	if abs(velocity.x) > abs(velocity.y):
		direction_prefix = "side"
		sprite.flip_h = velocity.x < 0
	else:
		if velocity.y > 0:
			direction_prefix = "down"
		else:
			direction_prefix = "up"

	animation_player.play("%s_%s" % [animation_prefix, direction_prefix])
