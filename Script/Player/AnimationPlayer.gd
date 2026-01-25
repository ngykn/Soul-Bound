extends Node2D

signal attack_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_animation = $HurtAnimation

@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var hitbox = $"../Hitbox"

enum AnimState {
	IDLE,
	RUN,
	WALK,
	ATTACK,
	HIT,
	DASH,
	DEAD
}

const DEADZONE := 5.0

var state: AnimState = AnimState.IDLE
var direction_prefix := "down"
var facing_dir: Vector2 = Vector2.DOWN


# =========================
# PUBLIC API
# =========================
func set_move_velocity(velocity: Vector2):
	if state == AnimState.ATTACK or state == AnimState.HIT:
		return

	_update_direction(velocity)
	_update_movement_state(velocity)
	_play_current()

func play_attack():
	state = AnimState.ATTACK
	_face_hitbox_direction()
	_play_current()

func return_to_movement():
	state = AnimState.IDLE
	_play_current()

func hurt():
	hurt_animation.play("Hurt")

	await hurt_animation.animation_finished

func player_dead():
	state = AnimState.DEAD
	_play_current()

# =========================
# INTERNAL
# =========================
func _update_movement_state(velocity: Vector2):
	if velocity.length() < DEADZONE:
		state = AnimState.IDLE
	elif velocity.length() <= 50:
		state = AnimState.WALK
	else:
		state = AnimState.RUN
		

func _update_direction(velocity: Vector2):
	# Update facing ONLY when there is movement
	if velocity.length() >= DEADZONE:
		facing_dir = velocity.normalized()

	if abs(facing_dir.x) > abs(facing_dir.y):
		direction_prefix = "side"
		sprite.flip_h = facing_dir.x < 0
	else:
		direction_prefix = "down" if facing_dir.y > 0 else "up"

func _play_current():
	var anim := ""

	match state:
		AnimState.IDLE:
			anim = "idle_%s" % direction_prefix
		AnimState.RUN:
			anim = "run_%s" % direction_prefix
		AnimState.WALK:
			anim = "walk_%s" % direction_prefix
		AnimState.ATTACK:
			anim = "attack_%s" % direction_prefix
		AnimState.HIT:
			anim = "hit_%s" % direction_prefix
		#AnimState.DASH:
			#anim = "dash_%s" % direction_prefix
		AnimState.DEAD:
			anim = "dead_%s" % direction_prefix

	if animation_player.current_animation != anim:
		animation_player.play(anim)

func _face_hitbox_direction() -> void:
	match direction_prefix:
		"down":
			hitbox.position = Vector2.DOWN * 24
		"up":
			hitbox.position = Vector2.UP * 24
		"side":
			if sprite.flip_h:
				hitbox.position = Vector2.LEFT * 24
			else:
				hitbox.position = Vector2.RIGHT * 24

func _on_animation_player_animation_finished(anim_name):
	if state == AnimState.ATTACK or state == AnimState.HIT:
		if state == AnimState.ATTACK:
			emit_signal("attack_finished")

		return_to_movement()
