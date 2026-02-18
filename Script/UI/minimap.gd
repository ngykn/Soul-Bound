extends SubViewport

@onready var camera = $Camera

var player

func _ready():
	await get_tree().process_frame
	player = get_tree().current_scene.player
	
	world_2d = get_tree().root.world_2d
	
func _physics_process(delta):
	if player:
		camera.position = player.position
