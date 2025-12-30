class_name CameraController extends Camera2D

signal finished_pan
signal finished_pan_loop

enum Mode {
	FREE,
	FOLLOW,
	PAN,
	LOCKED
}

var mode : Mode = Mode.FREE
var target : Node2D = null
var tween : Tween = null

# Follow settings
var follow_speed := 5.0

# Shake
var shake_strength := 0.0
var shake_decay := 12.0

# Loop pan data
var loop_a : Vector2
var loop_b : Vector2
var loop_time : float

func _ready():
	self.add_to_group("camera")

func _process(delta):
	_apply_shake(delta)

	if mode == Mode.FOLLOW:
		_follow(delta)


# ========================
# PUBLIC API
# ========================

func pan_to(pos: Vector2, time := 1.0):
	_kill_tween()
	mode = Mode.PAN

	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"global_position",
		pos,
		time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_pan_finished)


func pan_loop(a: Vector2, b: Vector2, time := 1.0):
	_kill_tween()
	mode = Mode.PAN

	loop_a = a
	loop_b = b
	loop_time = time

	_start_pan_loop()


func follow(node: Node2D):
	_kill_tween()
	target = node
	mode = Mode.FOLLOW


func lock_at(pos: Vector2):
	_kill_tween()
	mode = Mode.LOCKED
	global_position = pos


func free():
	_kill_tween()
	mode = Mode.FREE


func zoom_to(value: Vector2, time := 0.5):
	_kill_tween()
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"zoom",
		value,
		time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func shake(amount := 10.0):
	shake_strength = max(shake_strength, amount)
# ========================
# INTERNAL
# ========================

func _follow(delta):
	if not is_instance_valid(target):
		mode = Mode.FREE
		return

	global_position = global_position.lerp(
		target.global_position,
		delta * follow_speed
	)


func _apply_shake(delta):
	if shake_strength > 0.0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerp(shake_strength, 0.0, delta * shake_decay)
	else:
		offset = Vector2.ZERO


func _start_pan_loop():
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", loop_a, loop_time)
	tween.tween_property(self, "global_position", loop_b, loop_time)
	tween.finished.connect(_start_pan_loop)

func _on_pan_finished():
	if mode == Mode.PAN:
		mode = Mode.FREE
		
	emit_signal("finished_pan")


func _kill_tween():
	if tween and tween.is_running():
		tween.kill()
	tween = null
