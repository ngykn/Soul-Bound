extends Scene

#@onready var apathy := $Apathy

func _ready():
	#DialogueManager.show_dialogue_balloon(load("res://Dialogue/dialogue.dialogue"),"this_is_a_node_title")
	#DialogueManager.dialogue_ended.connect(func(something): print("Done"))
	camera.follow(player)
	await get_tree().create_timer(1).timeout
	camera.pan_to($Apathy.global_position)
	#$Player.start_cutscene_move(Vector2(868,377))
	pass


func _on_area_cut_scene_player_entered():
	player.start_cutscene_move(Vector2(3699,526))
