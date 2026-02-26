extends Scene

@onready var apathy := $Apathy

@onready var apathy_area : AreaCutscene = $CutScene/Apathy
@onready var strange_man_area : AreaCutscene = $CutScene/StrangeMan

var _have_met_strange_man := false
var _have_met_apathy := false

func _ready() -> void:
	super._ready()
	await TransitionManager.scene_transition_finished
	await GlobalFunction.costumize_show_dialogue(load("res://Dialogue/chapter_one.dialogue"),"mc_awoke")
	ui.main_objectives.add_objective("Explore the unknown area")

func _strange_man_cutscene() -> void:
	if _have_met_strange_man:
		return

	player.start_cutscene_move(Vector2(2744,632))
	await player.cutscene_movement_finished
	await get_tree().create_timer(1).timeout
	player._handle_interaction()
	_have_met_strange_man = true
	ui.main_objectives.completed_objective("Explore the unknown area")


func _apathy_cutscene() -> void:
	if _have_met_apathy:
		return
	GameState.input_enabled = false
	player.start_cutscene_move(apathy_area.global_position)
	await player.cutscene_movement_finished
	await get_tree().create_timer(1).timeout
	GameState.input_enabled = true
	camera.lock_at(apathy_area.global_position)
	GlobalFunction.costumize_show_dialogue(load("res://Dialogue/chapter_one.dialogue"),"apathy_intro")
	await GlobalFunction.dialogue_ended
	$Apathy.dramatic_attack()
	$AudioStreamPlayer.play()

#Cut Scene
func _on_npc_dialogue_ended() -> void:
	TransitionManager.fade_in()
	await TransitionManager.animation_in_finished
	$NormalNpc.queue_free()
	TransitionManager.fade_out()

func _on_apathy_vulnerable():
	ui.main_objectives.completed_objective("Defeat Apathy")
	$ExitPoint/ExitPoint.set_collision_disabled(false)

func _player_dead() -> void:
	GlobalManager.player_life = 100
	get_tree().reload_current_scene()
