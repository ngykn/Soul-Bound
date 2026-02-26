class_name Despair extends CharacterBody2D

signal vulnerable
signal dead

@onready var animation_player = $AnimationPlayer
@onready var attack_anim := $AttackAnimation
@onready var hurt_animation = $HurtAnimation

@onready var arm_left := $Arm/ArmLeft
@onready var arm_right := $Arm/ArmRight

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

@export var basic_interval := 1.2
@export var echo_interval := 5.0
@export var orbit_interval := 14.0

@export var dialogue : DialogueResource
@export var title := ""

var life := 3
var _is_dead := false
var _is_hurt := false
var _is_vulnerable := false
var orb_scene := preload("res://Object/apathy_orb.tscn")
var hollow_bullet_scene := preload("res://Object/orb_bullet.tscn")
var empty_orbit_scene := preload("res://orbit_controller.tscn")

var recovery_time := 5.0
var basic_timer := 0.0
var echo_timer := 0.0
var orbit_timer := 0.0

var attack_count_before_recovery := 4
var attack_count := 0

var recovery := false
var _is_attacking := false
var player : Player

var active := false

func _ready():
	await get_tree().process_frame
	player = get_tree().current_scene.player


func _process(delta):
	if not active or _is_vulnerable:
		return

	if _is_attacking or not player or recovery or _is_dead:
		return

	basic_timer -= delta
	echo_timer -= delta
	orbit_timer -= delta

	_handle_recovery()
	handle_ai()

func _handle_recovery():
	if recovery or attack_count <= attack_count_before_recovery:
		return
	
	recovery = true
	await get_tree().create_timer(4).timeout
	attack_count_before_recovery = randi_range(3,6)
	recovery = false
	attack_count = 0

func handle_ai() -> void:
	# HOLLOW ECHO (highest priority)
	if global_position.distance_to(player.global_position) <= 100 and echo_timer <= 0:
		start_hollow_echo()
		return

	# EMPTY ORBIT 
	if orbit_timer <= 0:
		start_empty_orbit()
		return

	# BASIC ATTACK
	if basic_timer <= 0:
		start_basic_attack()

func start_basic_attack():
	_is_attacking = true
	basic_timer = basic_interval

	attack_anim.play("basic")
	await attack_anim.animation_finished

	for i in 3:
		spawn_orb()

	await arm_to_neutral()
	_is_attacking = false
	attack_count += 1

func start_hollow_echo():
	_is_attacking = true
	echo_timer = echo_interval

	attack_anim.play("echo")
	await attack_anim.animation_finished

	for i in 12:
		var b = hollow_bullet_scene.instantiate()
		b.global_position = global_position
		b.direction = Vector2.RIGHT.rotated(i * TAU / 12)
		b.set_to_bullet_variation("hollow")
		get_tree().current_scene.add_child(b)

	await arm_to_neutral()
	_is_attacking = false
	attack_count += 1

func start_empty_orbit():
	_is_attacking = true
	orbit_timer = orbit_interval

	attack_anim.play("orbit")
	await attack_anim.animation_finished

	var orbit = empty_orbit_scene.instantiate()
	get_tree().current_scene.add_child(orbit)

	await arm_to_neutral()
	_is_attacking = false
	attack_count += 1

func spawn_orb():
	var orb = orb_scene.instantiate()
	orb.global_position = global_position
	get_tree().current_scene.add_child(orb)

func arm_to_neutral():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	tween.tween_property(arm_left, "rotation", 0.0, 0.25)
	tween.tween_property(arm_left, "position", Vector2(-11, 8), 0.25)

	tween.tween_property(arm_right, "rotation", 0.0, 0.25)
	tween.tween_property(arm_right, "position", Vector2(13, 8), 0.25)

	await tween.finished

func _vulnerable() -> void:
	_is_vulnerable = true
	collision_shape.set_deferred("disabled", true)
	sprite.modulate = Color('#ffffff77')
	emit_signal("vulnerable")

func _handle_death() -> void:
	_is_dead = true
	if dialogue:
		GlobalFunction.costumize_show_dialogue(dialogue, title)
		await GlobalFunction.dialogue_ended

	animation_player.play("death")
	GlobalReferences.morality -= 10
	emit_signal("dead")

func _on_hurtbox_hurt(entity):
	if _is_dead or _is_hurt:
		return
	
	_is_hurt = true
	
	hurt_animation.play("hurt")
	
	var damageP := 1
	
	if GlobalManager.strength:
		damageP = 3

	life -= damageP
	if life <= 0:
		$Arm.hide()
		if _is_vulnerable:
			_handle_death()
			return
		_vulnerable()

	await hurt_animation.animation_finished
	_is_hurt = false
