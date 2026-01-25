extends CharacterBody2D

@onready var attack_anim: AnimationPlayer = $AttackAnimation
@onready var arm_aim: Node2D = $ArmAim

const BULLET_SCENE : PackedScene = preload("res://Object/orb_bullet.tscn")
const BURST_COUNT : int = 10
var arm_aim_speed := 4.0

var can_aim := true
var is_attacking := false

var target : Player
var target_position : Vector2
var threshold := 30

func _ready():
	await get_tree().process_frame
	target = get_tree().current_scene.player

func _physics_process(delta: float) -> void:
	if target:
		
		if global_position.distance_to(target.global_position) <= threshold  or is_attacking:
			velocity = Vector2.ZERO
		else:
			velocity = GlobalFunction.follow(velocity, global_position, target.global_position, 100)
		
		if can_aim and not is_attacking:
			_update_arm_aim(delta)
	
	if Input.is_action_just_pressed("attack"):
		slam_attack()

	move_and_slide()

func _update_arm_aim(delta: float) -> void:
	var target_angle := (
		(target.global_position - arm_aim.global_position) * -1
	).angle()

	arm_aim.rotation = lerp_angle(
		arm_aim.rotation,
		target_angle,
		arm_aim_speed * delta
	)

func swing_attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	attack_anim.play("swing")
	await attack_anim.animation_finished
	is_attacking = false

func slam_attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	can_aim = false

	await _tween_arm_to_neutral()

	attack_anim.play("slam")
	await attack_anim.animation_finished
	_fire_burst()

	get_tree().current_scene.camera.shake()

	attack_anim.play("slam_recover")
	await attack_anim.animation_finished

	can_aim = true
	is_attacking = false

func _tween_arm_to_neutral() -> void:
	var tween := create_tween()
	tween.tween_property(
		arm_aim,
		"rotation",
		0.0,
		0.3
	)
	await tween.finished

func _fire_burst():
	for i in BURST_COUNT:
		#await get_tree().create_timer(0.05).timeout
		var bullet = BULLET_SCENE.instantiate()
		var angle := TAU * i / BURST_COUNT

		bullet.global_position = $ArmAim/ArmSwing/Scythe/SpawnPoint.global_position
		bullet.direction = Vector2(cos(angle), sin(angle))

		get_parent().add_child(bullet)
