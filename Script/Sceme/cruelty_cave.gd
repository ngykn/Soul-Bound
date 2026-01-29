extends Scene

@onready var cruelty = $Cruelty
@onready var compassion : Compassion = $Compassion
@onready var cruelty_room =  $CrueltyRoom

var cruelty_dead := false

func _ready():
	super._ready()
	if GlobalReferences.killed_enemy.has(cruelty.ID):
		cruelty_dead = true
		GlobalFunction.disable_layer($TileMap,"Cage")
		cruelty.queue_free()
		compassion.queue_free()
		return
		
	cruelty.dead.connect(_on_cruelty_dead)

func _on_area_cut_scene_player_entered():
	if cruelty_dead:
		return
	
	GameState.input_enabled = false
	camera.pan_to(cruelty_room.global_position)
	await camera.finished_pan
	camera.lock_at(cruelty_room.global_position)
	GameState.input_enabled = true
	
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/cruelty_cave.dialogue"))
	await GlobalFunction.dialogue_ended
	cruelty.start()

func _on_cruelty_dead():
	await get_tree().process_frame
	GameState.input_enabled = false
	cruelty_dead = true
	
	GlobalFunction.disable_layer($TileMap,"Cage")
	
	compassion.go_to(player.global_position)
	await compassion.follow_finished
	
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/cruelty_cave.dialogue"),"compassion_rescued")
	await GlobalFunction.dialogue_ended
	
	await TransitionManager.fade_in()
	compassion.queue_free()
	await TransitionManager.fade_out()

	camera.pan_to(player.global_position)
	await camera.finished_pan
	camera.follow(player)
	GameState.input_enabled = true
