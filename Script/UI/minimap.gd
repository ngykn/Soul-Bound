extends SubViewport

@export var size_offset : float = 0.3

@onready var camera = $Camera
@onready var navigator = $Navigator
@onready var map_texture = $MapTexture
@onready var container = $"../.."
@onready var sub_viewport_container = $".."

var normal_size : float = 145.0
var v_offset : float
var h_offset : float
var expanded : float = false

var player
var cam

func _ready():
	await get_tree().process_frame

	var scene = get_tree().current_scene
	player = scene.player
	
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
		resize()
		#expand_map()

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

	if !expanded:
		tween.tween_property(container, "offset_left",v_offset + 5.0 , 0.2)
		tween.parallel().tween_property(container, "offset_bottom",h_offset + 5.0, 0.2)
		tween.parallel().tween_property(self, "size", Vector2i(v_offset,h_offset), 0.2)
		#tween.parallel().tween_property(camera,"position", cam_center(), 0.2)
	else:
		tween.tween_property(container, "offset_left",normal_size + 5.0, 0.2)
		tween.parallel().tween_property(container, "offset_bottom",normal_size + 5.0, 0.2)
		tween.parallel().tween_property(self, "size", Vector2i(normal_size,normal_size), 0.2)
		#tween.parallel().tween_property(camera,"position", player.position, 0.2)
	expanded = not expanded

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
		navigator.position = (player.position) * size_offset
		if player.velocity.length() > 0:
			navigator.rotation = player.velocity.angle()
		if !expanded:
			camera.position = (player.position) * size_offset
