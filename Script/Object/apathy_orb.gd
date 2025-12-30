extends CharacterBody2D

signal desolve

@export var move_speed := 120.0
@export var move_time := 1.2
@export var aim_offset_deg := 25.0
@export var burst_count := 12
@export var bullet_scene: PackedScene

var apathy : Apathy
var direction: Vector2
var stopped := false
var was_hit := false
var player: Node2D

@onready var move_timer: Timer = $MoveTimer
@onready var burst_timer: Timer = $BurstTimer


func _ready():
	randomize()

	player = get_tree().get_first_node_in_group("player")
	_set_aimed_direction()

	velocity = direction * move_speed

	move_timer.wait_time = move_time
	move_timer.timeout.connect(_stop_orb)
	move_timer.start()


func _physics_process(delta):
	if stopped:
		velocity = Vector2.ZERO
		return

	move_and_slide()

	# If hits wall early, stop immediately
	if get_slide_collision_count() > 0:
		_stop_orb()


func _set_aimed_direction():
	if not player:
		direction = Vector2.DOWN
		return

	var to_player := (player.global_position - global_position).normalized()
	var offset_rad := deg_to_rad(
		randf_range(-aim_offset_deg, aim_offset_deg)
	)

	direction = to_player.rotated(offset_rad)


func _stop_orb():
	if stopped:
		return

	stopped = true
	velocity = Vector2.ZERO

	burst_timer.wait_time = 0.4
	burst_timer.timeout.connect(_resolve)
	burst_timer.start()


func on_hit():
	if was_hit:
		return

	was_hit = true
	#queue_free()

func _resolve():
	if was_hit:
		queue_free()
		return

	await _fire_burst()
	queue_free()

func _fire_burst():
	for i in burst_count:
		#await get_tree().create_timer(0.05).timeout
		var bullet = bullet_scene.instantiate()
		var angle := TAU * i / burst_count

		bullet.global_position = global_position
		bullet.direction = Vector2(cos(angle), sin(angle))

		get_parent().add_child(bullet)
