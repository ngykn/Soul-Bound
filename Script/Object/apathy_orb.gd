class_name Orb extends CharacterBody2D

signal desolve

const MOVE_SPEED := 120.0
const MAX_MOVE_TIME := 2.5
const AIM_OFFSET_DEG := 25.0
const BURST_COUNT := 12
const BULLET_SCENE := preload("res://Object/orb_bullet.tscn")

var apathy : Apathy
var direction: Vector2
var stopped := false
var was_hit := false
var player: Node2D

@onready var animation_player = $AnimationPlayer
@onready var move_timer : Timer = $MoveTimer
@onready var burst_timer: Timer = $BurstTimer


func _ready():
	randomize()

	player = get_tree().get_first_node_in_group("player")
	_set_aimed_direction()

	velocity = direction * MOVE_SPEED
	move_timer.wait_time = ((global_position.distance_to(player.global_position) / 2) / MOVE_SPEED)
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
		randf_range(-AIM_OFFSET_DEG, AIM_OFFSET_DEG)
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

	await _desolve()
	await _fire_burst()
	emit_signal("desolve")
	queue_free()


func _fire_burst():
	for i in BURST_COUNT:
		#await get_tree().create_timer(0.05).timeout
		var bullet = BULLET_SCENE.instantiate()
		var angle := TAU * i / BURST_COUNT

		bullet.global_position = global_position
		bullet.direction = Vector2(cos(angle), sin(angle))

		get_parent().add_child(bullet)

func _fade_out(duration: float = 0.5):
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	await tween.finished

func _desolve() -> void:
	animation_player.play("explode")
	await animation_player.animation_finished
