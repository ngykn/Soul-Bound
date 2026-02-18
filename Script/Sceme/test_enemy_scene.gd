extends Scene


func _ready():
	ui.inventory._update_inventory("Sword")
	$CharacterBody2D.follow_finished.connect(func(): print("finish"))
	camera.follow(player)
	await get_tree().create_timer(3).timeout
	$CharacterBody2D.go_to(player.global_position)
	ui.main_objectives.add_objective("Testing")
	await get_tree().create_timer(1).timeout
	ui.main_objectives.completed_objective("Testing")
