class_name NPC extends CharacterBody2D

signal dialogue_started 
signal dialogue_ended

@export_category("Animation & Dialogue")
@export_enum("down","right","left","up")
var starting_direction := "down" ##The Original Facing Direction

@export var sprite_node : Node2D
@export var animation_manager : AnimationPlayer
@export var dialogue_id : DialogueResource
@export var dialogue_title : String


@onready var sprite_arr : Array[Sprite2D] =[]

var _return_to_original_direction : bool = true
var animation_action_prefix : String = "idle"
var animation_direction_prefix : String = "down"

func _ready():
	for sp in sprite_node.get_children():
		if sp is Sprite2D:
			sprite_arr.append(sp)

	_match_direction_using_string(starting_direction)
# ========================
# PUBLIC API
# ========================

func start_dialogue() -> void:
	if !dialogue_id:
		return
	emit_signal("dialogue_started")
	GlobalFunction.costumize_show_dialogue(dialogue_id, dialogue_title)
	await GlobalFunction.dialogue_ended
	emit_signal("dialogue_ended")
	
	if _return_to_original_direction:
		_match_direction_using_string(starting_direction)

func face_direction(direction : Vector2) -> void:
	_match_direciton(direction - global_position)


# ========================
# INTERNAL
# ========================

func _match_direciton(direction : Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		animation_manager.play("%s_side" % animation_action_prefix)
		flip_sprite(direction.x < 0)
	else:
		if direction.y > 0:
			animation_manager.play("%s_down" % animation_action_prefix)
		else:
			animation_manager.play("%s_up" % animation_action_prefix)

func flip_sprite(flip : bool) -> void:
	for sp in sprite_arr:
		sp.flip_h = flip


func _match_direction_using_string(direction_in_string : String):
	match direction_in_string:
		"up":
			face_direction(global_position + Vector2(0,-1))
		"down":
			face_direction(global_position + Vector2(0,1))
		"right":
			face_direction(global_position + Vector2(1,0))
		"left":
			face_direction(global_position + Vector2(-1,0))
