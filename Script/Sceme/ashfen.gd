extends Scene

var entered := false
@onready var apathy = $Apathy2


func _on_area_cut_scene_player_entered():
	if entered or not is_instance_valid(apathy):
		return
	
	$AudioStreamPlayer2.play()
	entered = true
	camera.pan_to($ApathyRoom.global_position)
	await camera.finished_pan
	camera.lock_at($ApathyRoom.global_position)
	$Apathy2.dramatic_attack()

func _on_apathy_2_vulnerable():
	$AudioStreamPlayer2.stop()
	GameState.input_enabled = false
	camera.pan_to(player.global_position)
	await camera.finished_pan
	camera.follow(player)
	GameState.input_enabled = true
