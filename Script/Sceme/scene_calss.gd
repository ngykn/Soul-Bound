class_name Scene extends Node2D

@export_category("Entry Points")
@export var entry_point : Node2D
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var camera : CameraController = get_tree().get_first_node_in_group("camera")
@onready var ui : UI = get_tree().get_first_node_in_group("ui")
var entry_points := {}

func _ready():
	camera.follow(player)
	player.dead.connect(_player_dead)
	if entry_point:
		for p in entry_point.get_children():
			entry_points[p.name] = p

	if GameState.next_spawn_id: 
		match_entry_point(GameState.next_spawn_id)

func match_entry_point(entry_point_id: String) -> void:
	if not entry_points.has(entry_point_id):
		push_error("Entry point not found: " + entry_point_id)
		return

	var spawn: SceneEntryPoint = entry_points[entry_point_id]
	camera.global_position = spawn.global_position
	player.global_position = spawn.global_position
	player.face_cardinal_direction(spawn.face_on_spawn)

func _player_dead() -> void:
	await get_tree().create_timer(0.5).timeout
	GlobalManager.player_life = 100
	TransitionManager.go_to_chunk(self, "res://Scene/middlehaven.tscn", "South")
