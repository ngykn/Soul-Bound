class_name Compassion extends CharacterBody2D

signal follow_finished

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

enum State {
	IDLE,
	FOLLOW
}

var current_state := State.IDLE
var target : Vector2
var treshold : float

func _physics_process(delta):
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.FOLLOW:
			_handle_follow()
	
	_animation_manager()
	move_and_slide()

func go_to(target_position : Vector2, set_threshold := 24.0) -> void:
	current_state = State.FOLLOW
	target = target_position
	treshold = set_threshold

func _handle_follow() -> void:
	if global_position.distance_to(target) <= treshold:
		current_state = State.IDLE
		emit_signal("follow_finished")
		return
	
	velocity = GlobalFunction.follow(
		velocity,
		global_position,
		target,
		100
		)

func _animation_manager() -> void:
	if velocity > Vector2.ZERO:
		animation_player.play("run")
	else:
		animation_player.play("idle")
	
	if abs(velocity.x) > 0.01:
		sprite.flip_h = velocity.x < 0
