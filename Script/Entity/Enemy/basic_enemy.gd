class_name BASIC_ENEMY extends CharacterBody2D

var player
var THRESHOLD : float = 400.0
var speed := 60.0

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
