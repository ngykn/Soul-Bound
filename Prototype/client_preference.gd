extends Window

@onready var firefly = $"../CameraController/Firefly"
@onready var fog = $"../Fog"

func _ready():
	close_requested.connect(func(): hide())
	

func _on_shader_toggled(toggled_on):
	get_tree().current_scene.material.set_shader_parameter("enabled", toggled_on)
	print("Shader: ", toggled_on)
	
func _on_fog_toggled(toggled_on):
	fog.visible = toggled_on
	print("Fog: ", toggled_on)

func _on_fire_fly_toggled(toggled_on):
	firefly.visible = toggled_on
	print("Orb: ", toggled_on)
