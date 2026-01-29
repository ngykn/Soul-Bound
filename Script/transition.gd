class_name Transition extends CanvasLayer

signal scene_transition_finished
signal animation_in_finished
signal animation_out_finished

@onready var animation_player = $AnimationPlayer
@onready var text_label = $RichTextLabel
@onready var text_animation = $TextAnimation


func change_scene(from, to_next_scene : String) -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	from.get_tree().call_deferred("change_scene_to_file", to_next_scene)
	animation_player.play("fade_out")
	await animation_player.animation_finished

	emit_signal("scene_transition_finished")


func go_to_chunk(from : Node2D, to_next_chunk : String, next_entry_point_id: String) -> void:
	if !ResourceLoader.exists(to_next_chunk):
		assert("Not Found: " + to_next_chunk)
	
	GameState.next_spawn_id = next_entry_point_id
	animation_player.play("fade_in")
	await animation_player.animation_finished

	from.get_tree().call_deferred("change_scene_to_file", to_next_chunk)
	animation_player.play("fade_out")
	await animation_player.animation_finished

	emit_signal("scene_transition_finished")

#Developer Note: Outdated Fucntion
func entering_house_transition(to: Vector2) -> void:
	var player: Player = get_tree().current_scene.player
	var camera : CameraController = get_tree().current_scene.camera
	if !player and !camera:
		printerr("No player detected")
		return

	GameState.input_enabled = false

	await slide_in()

	# TELEPORT
	#player.global_position = to
	camera.global_position = to
	player.global_position = to
	GameState.input_enabled = true

	await slide_out()

#Develoepr Note: Updated House Entry transition
func cave_entry_transition(cave_exit : SceneEntryPoint) -> void:
	if !cave_exit:
		printerr("Null Cave Exit")
		return
	
	var player: Player = get_tree().current_scene.player
	var camera : CameraController = get_tree().current_scene.camera

	GameState.input_enabled = false
	
	await slide_in()

	camera.global_position = cave_exit.global_position
	player.global_position = cave_exit.global_position
	
	camera.set_bounds(cave_exit.get_limit_to_array())
	
	GameState.input_enabled = true

	await slide_out()

# =========================
# ANIMATION IN
# =========================
func fade_in() -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	emit_signal("animation_in_finished")


func slide_in() -> void:
	animation_player.play("slideY_in")
	await animation_player.animation_finished
	emit_signal("animation_in_finished")
# =========================
# ANIMATION OUT
# =========================
func fade_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	emit_signal("animation_out_finished")

func slide_out() -> void:
	animation_player.play("slideY_out")
	await animation_player.animation_finished
	emit_signal("animation_in_finished")

# =========================
# TEXT ANIMATION
# =========================
func text_animation_fade(text : Array[String], delay : float = 1.0) -> void:
	await fade_in()
	text_label.visible_ratio = 1
	for i in text:
		text_label.text = "[center]" + i +"[/center]"
		text_animation.play("text_in")
		await text_animation.animation_finished
		await get_tree().create_timer(delay).timeout
		text_animation.play("text_out")
		await text_animation.animation_finished
	
	text_label.visible_ratio = 0
	await fade_out()

func text_animation_ratio(text : Array[String], delay : float = 1.0) -> void:
	await fade_in()
	text_label.modulate.a = 1
	text_label.visible_ratio = 0
	for i in text:
		text_label.text = "[center]" + i +"[/center]"
		await tween_ratio(1)
		await get_tree().create_timer(delay).timeout
		await tween_ratio(0)
	text_label.modulate.a = 0
	await fade_out()

func tween_ratio(value) -> void:
	var t = create_tween()
	t.tween_property(text_label, "visible_ratio", value, 0.5)
	await t.finished
