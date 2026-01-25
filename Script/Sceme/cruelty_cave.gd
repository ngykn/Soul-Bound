extends Scene

var cruelty_dead := false

func _on_area_cut_scene_player_entered():
	if cruelty_dead:
		return

	GameState.input_enabled = false
	camera.pan_to($CrueltyRoom.global_position)
	await camera.finished_pan
	camera.lock_at($CrueltyRoom.global_position)
	GameState.input_enabled = true
	$Cruelty.start()


func _on_cruelty_dead():
	cruelty_dead = true
	GameState.input_enabled = false
	camera.pan_to(player.global_position)
	await camera.finished_pan
	camera.follow(player)
	GameState.input_enabled = true
