extends SubViewport

signal maximize
signal minimize
signal compass_close(value : bool)

@export var size_offset : float = 0.3

@onready var camera = $Camera
@onready var navigator = $Navigator
@onready var map_texture = $MapTexture
@onready var container = $"../.."
@onready var sub_viewport_container = $".."
@onready var compass = $"../../Compass"
@onready var compass_hand := $"../../Compass/Hands"

var normal_size : float = 145.0
var v_offset : float
var h_offset : float
var expanded : float = false

var _can_change_compass_visiblity : bool = true

var player : Player
var map_offset : Vector2

func _ready():
	await get_tree().process_frame
	
	var scene = get_tree().current_scene
	if scene is Scene:
		player = scene.player
	if GlobalReferences.map_offset.has(scene.name):
		map_offset = GlobalReferences.map_offset[scene.name]

	if not GlobalReferences.minimap_texture.has(scene.name):
		return

	var minimap_data = GlobalReferences.minimap_texture[scene.name]
	var tex: Texture2D = minimap_data[0]
	size_offset = minimap_data[1]

	map_texture.texture = tex
	map_texture.size = tex.get_size()
	map_texture.scale = Vector2.ONE * size_offset

	var tex_size = tex.get_size()
	h_offset = tex_size.x * size_offset
	v_offset = tex_size.y * size_offset

	camera.position = player.position * size_offset

func _unhandled_key_input(event):
	if event.is_action_pressed("reload_game"):
		expand_map()

	if event.is_action_pressed("compass") and _can_change_compass_visiblity:
		close_compass(compass.visible)

func close_compass(close) -> void:
	compass.visible = !close
	emit_signal("compass_close", !close)

func resize() -> void:
	if !expanded:
		container.offset_left = (h_offset + 5.0) *-1
		container.offset_bottom = v_offset
		size = Vector2i(h_offset,v_offset)
		camera.position = cam_center()
	else:
		container.offset_left = (normal_size + 5.0) * -1
		container.offset_bottom = normal_size + 5.0
		size = Vector2i(normal_size,normal_size)

	expanded = not expanded

func expand_map() -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	if !expanded:
		tween.tween_property(container, "offset_left", (h_offset + 5.0) * -1, 0.2)
		tween.tween_property(container, "offset_bottom", v_offset, 0.2)
		tween.tween_property(self, "size", Vector2i(h_offset, v_offset), 0.2)
		tween.tween_property(camera, "position", cam_center(), 0.2)
		emit_signal("maximize")
	else:
		tween.tween_property(container, "offset_left", (normal_size + 5.0) * -1, 0.2)
		tween.tween_property(container, "offset_bottom", normal_size + 5.0, 0.2)
		tween.tween_property(self, "size", Vector2i(normal_size, normal_size), 0.2)
		emit_signal("minimize")

	expanded = !expanded

func cam_center():
	var t = map_texture
	var s = (t.size / 2) * size_offset
	return s

func generate_minmap():
	var mapN = get_tree().current_scene.name
	await RenderingServer.frame_post_draw
	var image = get_texture().get_image()
	image.save_png("user://" + mapN + ".png")

func _physics_process(delta):
	if player:
		if GlobalReferences.map_compass_sequence.size() > GlobalReferences.map_sequence:
			var dir = (
				(GlobalReferences.map_compass_sequence[GlobalReferences.map_sequence]) - 
				(map_offset + player.global_position)
			).normalized()

			compass_hand.rotation = dir.angle()

		navigator.position = (player.position) * size_offset

		if player.velocity.length() > 0:
			navigator.rotation = player.velocity.angle()
		if !expanded:
			camera.position = (player.position) * size_offset
