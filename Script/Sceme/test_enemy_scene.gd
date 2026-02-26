extends Scene


func _ready():
	ui.inventory._update_inventory("Sword")
	ui.inventory._update_inventory("Dash Ring")
	camera.follow(player)

func _unhandled_key_input(event):
	if event.is_action_pressed("reload_game"):
		_player_dead()

func _player_dead() -> void:
	await get_tree().create_timer(0.5).timeout
	GlobalManager.player_life = 100
	get_tree().reload_current_scene()

func to_png() -> void:
	pass
