extends Scene


func _ready():
	$CharacterBody2D.follow_finished.connect(func(): print("finish"))
	camera.follow(player)
	await get_tree().create_timer(3).timeout
	print("Go")
	$CharacterBody2D.go_to(player.global_position)
