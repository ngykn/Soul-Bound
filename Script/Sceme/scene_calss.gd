class_name Scene extends Node2D

@export_category("Entry Points")
@export var entry_point : Node2D
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var camera : CameraController = get_tree().get_first_node_in_group("camera")
@onready var ui : UI = get_tree().get_first_node_in_group("ui")
var entry_points := {}

var map := [
	"res://Scene/barrenland.tscn",
	"res://Scene/middlehaven.tscn",
	"res://Scene/ashenway.tscn",
	"res://Scene/ashfen.tscn",
	"res://Scene/ashfen_cave.tscn",
	"res://Scene/cruelty_cave.tscn",
	"res://Scene/southfield.tscn",
	"res://Scene/westfield.tscn",
	"res://Scene/highlands.tscn",
	"res://Scene/highlands_cave.tscn",
	"res://Scene/despair_cave.tscn"
]

#func _unhandled_key_input(event):
	#if event is InputEventKey and event.pressed:
		#match event.keycode:
			#KEY_1:
				#TransitionManager.change_scene(self,map[0])
			#KEY_2:
				#TransitionManager.change_scene(self,map[1])
			#KEY_3:
				#TransitionManager.change_scene(self,map[2])
			#KEY_4:
				#TransitionManager.change_scene(self,map[3])
			#KEY_5:
				#TransitionManager.change_scene(self,map[4])
			#KEY_6:
				#TransitionManager.change_scene(self,map[5])
			#KEY_7:
				#TransitionManager.change_scene(self,map[6])
			#KEY_8:
				#TransitionManager.change_scene(self,map[7])
			#KEY_9:
				#TransitionManager.change_scene(self,map[8])
			#KEY_0:
				#TransitionManager.change_scene(self,map[9])
func _ready():
	print(GlobalReferences.map_sequence)
	camera.follow(player)
	player.dead.connect(_player_dead)
	if entry_point:
		for p in entry_point.get_children():
			entry_points[p.name] = p

	if GameState.next_spawn_id: 
		match_entry_point(GameState.next_spawn_id)
		
	await TransitionManager.scene_transition_finished
	GameState.input_enabled = true

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
