extends Control


func _on_play_pressed():
	TransitionManager.change_scene(self,"res://UI/second_scene.tscn")
	pass # Replace with function body.


func _on_setting_pressed():
	TransitionManager.change_scene(self, "res://UI/setting.tscn")

func _on_exit_pressed():
	get_tree().quit()
