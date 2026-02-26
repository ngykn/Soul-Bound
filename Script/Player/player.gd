class_name Player extends CharacterBody2D

signal cutscene_movement_finished
signal dead

@export_category("Health & Armor")
@export var health := GlobalManager.player_life
@export var armor := GlobalManager.armor ##min 0 | max 70

@export_category("Face Direction")
@export_enum("north","east","south","west")
var starting_face_direction := "north" ## Developer note: (ToT) I realize it too late, so opposite po yung effect nya

@onready var animation_manager := $AnimationPlayer
@onready var collision_shape := $CollisionShape2D
@onready var interaction_area := $InteractionArea
@onready var hurtbox = $Hurtbox
@onready var light = $Light

enum MoveMode {
	PLAYER,
	CUTSCENE
}

var can_interact := false
var current_npc : NPC = null
var move_mode : MoveMode = MoveMode.PLAYER

const BOOTS_SPEED := 200
const WALK_SPEED := 100
const SLOW_SPEED := 50
const CUTSCENE_SPEED := 80
const STOP_DISTANCE := 4.0

var is_hurt := false
var is_dead := false
var is_attacking := false

var camera : Camera2D

var move_input := Vector2.ZERO
var cutscene_target := Vector2.ZERO
var cutscene_finished := false

var is_shield_active : bool = false

var is_boots_active : bool = false

const DASH_SPEED := 350
const DASH_DURATION := 0.15
const DASH_COOLDOWN := 5.0

var is_dashing := false
var dash_time := 0.0
var dash_cooldown := 0.0
var dash_dir := Vector2.ZERO


func _ready() -> void:
	hurtbox.hurt.connect(_handle_hit)
	interaction_area.npc_entered.connect(_handle_interaction_area.bind("entered"))
	interaction_area.npc_exited.connect(_handle_interaction_area.bind("exited"))
	camera = get_viewport().get_camera_2d()
	
	face_cardinal_direction(starting_face_direction)

func _unhandled_key_input(event) -> void:
	if is_dead:
		return

	if event.is_action_pressed("shield") and GlobalManager.shield > 0:
		is_shield_active = true
		material.set_shader_parameter("enabled", true)

	elif event.is_action_released("shield"):
		is_shield_active = false
		material.set_shader_parameter("enabled", false)

	if !move_mode == MoveMode.PLAYER and !GameState.input_enabled:
		return

	if Input.is_action_just_pressed("attack") and GlobalReferences.inventory.has("Sword"):
		_handle_attack()

	if Input.is_action_just_pressed("interact"):
		_handle_interaction()


func _physics_process(delta) -> void:
	if is_dead:
		return

	is_boots_active = (GlobalManager.boots)

	if dash_cooldown > 0:
		dash_cooldown -= delta

	if is_dashing:
		_handle_dash(delta)
	else:
		match move_mode:
			MoveMode.PLAYER:
				_handle_player_movement()
			MoveMode.CUTSCENE:
				_handle_cutscene_movement()

	velocity = move_input
	move_and_slide()

	if move_mode == MoveMode.PLAYER:
		_clamp_to_camera()

	animation_manager.set_move_velocity(velocity)
# =========================
# PUBLIC API
# =========================


func start_cutscene_move(target_pos: Vector2) -> void: ## Player Cutscene.
	move_mode = MoveMode.CUTSCENE
	cutscene_target = target_pos
	cutscene_finished = false


func face_cardinal_direction(cardinal_direction : String) -> void:
	var cdir := cardinal_direction.to_lower()
	match cdir:
		#Developer note: It doesn't work if I use (1,1) it should be equal or greater than 5 to work
		"north":
			_face_direction(Vector2(0,5))
		"east":
			_face_direction(Vector2(-5,0))
		"south":
			_face_direction(Vector2(0,-5))
		"west":
			_face_direction(Vector2(5,0))
			#_face_direction(Vector2.RIGHT)
		_:
			push_error("Invalid Cardinal Direction")

func player_light(enabled : bool, size : float = 1.0) -> void:
	light.enabled = enabled
	light.texture_scale = size

# ========================
# INTERNAL
# ========================

func _handle_player_movement() -> void:
	if !GameState.input_enabled or is_attacking:
		move_input = Vector2.ZERO
		return

	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if Input.is_action_just_pressed("dash") and GlobalReferences.inventory.has("Dash Ring"):
		_try_dash()
		return

	var speed := WALK_SPEED
	if Input.is_action_pressed("slow_movement"):
		speed = SLOW_SPEED
	elif is_boots_active:
		speed = BOOTS_SPEED

	move_input = input_dir.normalized() * speed

func _try_dash() -> void:
	if is_attacking or is_dashing or dash_cooldown > 0:
		return

	is_dashing = true
	dash_time = DASH_DURATION
	dash_cooldown = DASH_COOLDOWN

	# Dash uses facing direction, not input
	dash_dir = animation_manager.facing_dir.normalized()
	if dash_dir == Vector2.ZERO:
		dash_dir = Vector2.DOWN

	#animation_manager.play_dash()

func _handle_dash(delta) -> void:
	dash_time -= delta
	move_input = dash_dir * DASH_SPEED

	if dash_time <= 0:
		is_dashing = false
		move_input = Vector2.ZERO
		animation_manager.return_to_movement()


func _handle_cutscene_movement() -> void: ##Cutscene movement
	var dir := cutscene_target - global_position

	if dir.length() <= STOP_DISTANCE:
		move_input = Vector2.ZERO
		move_mode = MoveMode.PLAYER
		cutscene_finished = true
		emit_signal("cutscene_movement_finished")
		return

	move_input = dir.normalized() * CUTSCENE_SPEED


func _handle_interaction_area(npc : NPC, mode : String) -> void:
	match mode:
		"entered":
			current_npc = npc
			can_interact = true
		"exited":
			current_npc = null
			can_interact = false
		_:
			printerr("handle interaction error:")


func _handle_interaction() -> void: ##Player -> NPC Interaction
	if !current_npc:
		return

	_face_direction(current_npc.global_position - global_position)
	current_npc.face_direction(global_position)
	_handle_npc_dialogue()


func _handle_attack() -> void:
	if is_attacking or is_dashing:
		return
	
	animation_manager.play_attack()
	is_attacking = true
	await animation_manager.attack_finished
	is_attacking = false


func _handle_npc_dialogue() -> void:
	if !current_npc:
		return

	current_npc.start_dialogue()
	await current_npc.dialogue_ended
	current_npc = null


func _handle_hit(instance : Node2D) -> void:
	if !camera or is_hurt or is_dead:
		return

	if is_shield_active:
		GlobalManager.shield -= 1
		is_shield_active = false
		material.set_shader_parameter("enabled", false)
		return

	is_hurt = true
	camera.shake()
	
	if armor > 0:
		health -= randf_range(5.0,10.0)
		armor -= randf_range(5.0,20.0)
		GlobalManager.player_life = health
		GlobalManager.armor = armor
	else:
		health -= randf_range(10.0,20.0)
		GlobalManager.player_life = health
		GlobalManager.armor = armor

	await animation_manager.hurt()
	
	if health <= 0:
		is_dead = true
		animation_manager.player_dead()
		emit_signal("dead")
	
	is_hurt = false

func _face_direction(direction : Vector2) -> void:
	animation_manager._update_direction(direction)

func _clamp_to_camera() -> void:
	if camera == null:
		return

	var viewport_size := get_viewport_rect().size
	var zoom := camera.zoom
	var half_size := (viewport_size / zoom) * 0.5
	var cam_pos := camera.global_position

	var view_min := cam_pos - half_size
	var view_max := cam_pos + half_size

	var padding := 8.0

	global_position.x = clamp(global_position.x, view_min.x + padding, view_max.x - padding)
	global_position.y = clamp(global_position.y, view_min.y + padding, view_max.y - padding)
	
