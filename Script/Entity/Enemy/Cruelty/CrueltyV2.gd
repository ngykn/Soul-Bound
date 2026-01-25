extends CharacterBody2D

signal dead

@export var life : = 3

@export var min_x : int
@export var min_y : int
@export var max_x : int
@export var max_y : int

@onready var movement_anim = $MovementAnimation
@onready var attack_anim: AnimationPlayer = $AttackAnimation
@onready var arm_aim: Node2D = $ArmAim
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurt_animation = $HurtAnimation

const BULLET_SCENE: PackedScene = preload("res://Object/orb_bullet.tscn")
const BURST_COUNT := 16
@onready var spawn_point : Marker2D = $ArmAim/ArmSwing/Scythe/SpawnPoint


#Damage
var _is_hurt := false
var _is_dead := false

#movement
var arm_aim_speed := 4.0
var move_speed := 100.0

#Attacj
var can_aim := true
var is_attacking := false

#Target
var target: Player
var threshold := 30.0

#AI
enum AIState { IDLE, DECIDING, CHARGE, SLAM, RETREAT, DEAD}
var ai_state: AIState = AIState.IDLE
var previous_state : AIState
var retreat_target: Vector2


func start() -> void:
	target = get_tree().current_scene.player
	_start_idle()

func _physics_process(delta: float) -> void:
	if not target or _is_dead:
		return

	#_flip_sprite()
	_handle_animation()
	_handle_ai(delta)

	if can_aim and not is_attacking:
		_update_arm_aim(delta)

	move_and_slide()

# =========================
# ANIMATION
# =========================
func _handle_animation() -> void:
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

	if velocity.length() != 0:
		movement_anim.play("run")
	else:
		movement_anim.play("idle")

# =========================
# AI
# =========================
func _handle_ai(delta: float) -> void:
	match ai_state:
		AIState.IDLE:
			velocity = Vector2.ZERO

		AIState.CHARGE:
			velocity = GlobalFunction.follow(
				velocity,
				global_position,
				target.global_position,
				move_speed
			)

			if global_position.distance_to(target.global_position) <= threshold:
				swing_attack()

		AIState.RETREAT:
			velocity = GlobalFunction.follow(
				velocity,
				global_position,
				retreat_target,
				move_speed
			)

			if global_position.distance_to(retreat_target) <= 20:
				_start_idle()

# =========================
# DECISION
# =========================
func _start_idle() -> void:
	if ai_state == AIState.DEAD:
		return

	ai_state = AIState.IDLE
	await get_tree().create_timer(randf_range(0.0, 1.5)).timeout
	_decide_next_action()

func _decide_next_action() -> void:
	if ai_state == AIState.DEAD:
		return

	ai_state = AIState.DECIDING

	var roll := randf()

	if roll < 0.4:
		ai_state = AIState.CHARGE
		previous_state = AIState.CHARGE
	elif roll < 0.7:
		await slam_attack()
	else:
		if !previous_state == AIState.RETREAT:
			_start_retreat()
			previous_state = AIState.RETREAT
		else:
			_decide_next_action()

# =========================
# MORE ON MOVEMENT
# =========================
func _start_retreat() -> void:
	ai_state = AIState.RETREAT
	retreat_target = _get_random_corner()

func _get_random_corner() -> Vector2:
	var viewport := get_viewport_rect().size
	return Vector2(
		randi_range(min_x, max_x),
		randi_range(min_y, max_y)
	)

func _update_arm_aim(delta: float) -> void:
	var target_angle := (
		(target.global_position - arm_aim.global_position) * -1
	).angle()

	arm_aim.rotation = lerp_angle(
		arm_aim.rotation,
		target_angle,
		arm_aim_speed * delta
	)

#func _flip_sprite() -> void:
	#sprite.flip_h = target.global_position.x < global_position.x

func _tween_arm_to_neutral() -> void:
	var tween := create_tween()
	tween.tween_property(arm_aim, "rotation", 0.0, 0.3)
	await tween.finished

# =========================
# ATTACKS
# =========================
func swing_attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	ai_state = AIState.IDLE

	attack_anim.play("swing")
	await attack_anim.animation_finished

	is_attacking = false
	_start_idle()

func slam_attack() -> void:
	if is_attacking:
		return
	
	#Face Player
	sprite.flip_h = (global_position > target.global_position)
	
	is_attacking = true
	can_aim = false
	ai_state = AIState.IDLE

	await _tween_arm_to_neutral()

	attack_anim.play("slam")
	await attack_anim.animation_finished

	_fire_burst()
	get_tree().current_scene.camera.shake()

	attack_anim.play("slam_recover")
	await attack_anim.animation_finished

	can_aim = true
	is_attacking = false
	_start_idle()

func _fire_burst() -> void:
	var spawn := spawn_point.global_position

	for i in BURST_COUNT:
		var bullet := BULLET_SCENE.instantiate()
		var angle := TAU * i / BURST_COUNT

		bullet.global_position = spawn
		bullet.direction = Vector2(cos(angle), sin(angle))

		get_parent().add_child(bullet)


func _handle_death() -> void:
	await _tween_arm_to_neutral()
	movement_anim.play("dead")
	attack_anim.play("dead")
	emit_signal("dead")

func _on_hurtbox_hurt(entity):
	if _is_hurt or _is_dead:
		return

	_is_hurt = true

	life -= 1

	hurt_animation.play("hurt")
	await hurt_animation.animation_finished
	_is_hurt = false

	if life == 0:
		_is_dead = true
		_handle_death()
		ai_state = AIState.DEAD
		
