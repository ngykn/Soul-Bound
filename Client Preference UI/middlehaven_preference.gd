extends Window

signal fog(value : bool)
signal orb(value : bool)

func _ready():
	close_requested.connect(func(): hide())
	

func _on_shader_toggled(toggled_on):
	get_tree().current_scene.material.set_shader_parameter("enabled", toggled_on)

func _on_fog_toggled(toggled_on):
	emit_signal("fog", toggled_on)

func _on_fire_fly_toggled(toggled_on):
	emit_signal("orb", toggled_on)
