class_name Player extends CharacterBody2D

@onready var animation_manager = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

enum MoveMode {
	PLAYER,
	CUTSCENE
}

var move_mode : MoveMode = MoveMode.PLAYER

const WALK_SPEED := 100
const SLOW_SPEED := 50
const CUTSCENE_SPEED := 80
const STOP_DISTANCE := 4.0

var camera : Camera2D

var move_input := Vector2.ZERO
var cutscene_target := Vector2.ZERO
var cutscene_finished := false

func _ready():
	camera = get_viewport().get_camera_2d()

func _physics_process(delta):
	match move_mode:
		MoveMode.PLAYER:
			_handle_player_movement()
		MoveMode.CUTSCENE:
			_handle_cutscene_movement()

	velocity = move_input
	move_and_slide()

	if move_mode == MoveMode.PLAYER:
		_clamp_to_camera()

	animation_manager.change_animation(velocity)

# =========================
# PLAYER MOVEMENT
# =========================
func _handle_player_movement():
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	var speed := WALK_SPEED
	if Input.is_action_pressed("slow_movement"):
		speed = SLOW_SPEED

	move_input = input_dir.normalized() * speed

# =========================
# CUTSCENE MOVEMENT
# =========================
func start_cutscene_move(target_pos: Vector2):
	move_mode = MoveMode.CUTSCENE
	cutscene_target = target_pos
	cutscene_finished = false

func _handle_cutscene_movement():
	var dir := cutscene_target - global_position

	if dir.length() <= STOP_DISTANCE:
		move_input = Vector2.ZERO
		move_mode = MoveMode.PLAYER
		cutscene_finished = true
		return

	move_input = dir.normalized() * CUTSCENE_SPEED

# =========================
# CAMERA CLAMP
# =========================
func _clamp_to_camera():
	if camera == null:
		camera = get_viewport().get_camera_2d()
		if camera == null:
			return

	var rect := get_viewport_rect()
	var half_view := rect.size * 0.5 / camera.zoom

	var radius := 12.0

	var min_x := camera.global_position.x - half_view.x + radius
	var max_x := camera.global_position.x + half_view.x - radius
	var min_y := camera.global_position.y - half_view.y + radius
	var max_y := camera.global_position.y + half_view.y - radius

	if global_position.x <= min_x or global_position.x >= max_x:
		velocity.x = 0
	global_position.x = clamp(global_position.x, min_x, max_x)

	if global_position.y <= min_y or global_position.y >= max_y:
		velocity.y = 0
	global_position.y = clamp(global_position.y, min_y, max_y)
