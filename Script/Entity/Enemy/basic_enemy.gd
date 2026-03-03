class_name BASIC_ENEMY extends CharacterBody2D

@onready var arm_aim :Node2D = $ArmAim
@onready var raycast = $RayCast2D
@onready var life_bar = $ProgressBar
@onready var sprite :Sprite2D = $Sprite2D

@onready var attack_animation = $AttackAnimation
@onready var hurt_animation = $HurtAnimation
@onready var movement_animation = $MovementAnimation

var player
var THRESHOLD : float = 400.0
var speed := 40.0
var _dead : bool = false
var arm_aim_speed := 4.0
var lifebar_close_timer :float = 0.0 #max 1.5
var _attacking : bool = false

func _ready():
	await get_tree().process_frame
	player = get_tree().current_scene.player

func move():
	return GlobalFunction.follow(
		velocity,
		global_position,
		player.global_position,
		speed
	)

func player_is_near() -> bool:
	if !player:
		assert("player: null")

	return player_distance() <= THRESHOLD

func player_is_in_position(min, max) -> bool:
	if !player:
		assert("player: null")

	return player_distance() >= min and player_distance() <= max

func player_distance() -> float:
	if !player:
		assert("player: null")

	return global_position.distance_to(player.global_position)

func _update_arm_aim(delta: float) -> void:
	var target_angle = (
		(player.global_position - arm_aim.global_position)
	).angle()

	arm_aim.rotation = lerp_angle(
		arm_aim.rotation,
		target_angle,
		arm_aim_speed * delta
	)

func _tween_arm_to_neutral() -> void:
	var tween := create_tween()
	tween.tween_property(arm_aim, "rotation", 0.0, 0.3)
	await tween.finished

func effects(value : int) -> void:
	var coin := Label.new()
	var font := preload("res://Assets/Game Paused DEMO.otf")
	get_parent().add_child(coin)
	coin.text = "+$" + str(value)
	coin.label_settings = LabelSettings.new()
	coin.label_settings.font = font
	coin.label_settings.font_size = 12
	
	var coin_offset = Vector2(coin.size.x * 0.5, 20) * -1
	coin.position = global_position + coin_offset

	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(coin, "position:y", coin.position.y - 40, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(coin, "position:y", coin.position.y, 0.25).set_ease(Tween.EASE_IN).set_delay(0.25)

	await tween.finished
	coin.queue_free()
