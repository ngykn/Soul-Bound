extends Scene


@onready var hope = $Hope
@onready var despair = $Despair
@onready var room_center = $RoomCenter

func _ready():
	super._ready()
	camera.lock_at(room_center.global_position)
	despair.vulnerable.connect(despair_vulnerable)
	despair.dead.connect(despair_defeated)
	hope.dialogue_ended.connect(end)
	
	ui.minimap.close_compass(true)
	ui.minimap._can_change_compass_visiblity = false

	await TransitionManager.scene_transition_finished
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/despair.dialogue"),"pre_fight_despair")
	await GlobalFunction.dialogue_ended
	ui.main_objectives.add_objective("Defeat Despair")
	despair.active = true
	await ui.main_objectives.completed_objective("Locate Despair")
	ui.main_objectives.add_objective("Defeat Despair")

func despair_defeated() -> void:
	ui.main_objectives.completed_objective("Defeat Despair")
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/despair.dialogue"),"Hope")
	await GlobalFunction.dialogue_ended
	hope.queue_free()
	NpcManager.hope_is_alive = false
	end()

func despair_vulnerable() -> void:
	ui.main_objectives.completed_objective("Defeat Despair")
	hope.dialogue_id = preload("res://Dialogue/despair.dialogue")
	hope.dialogue_title = "spared_despair"
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/despair.dialogue"),"despair_vulnerable")
	
func end() -> void:
	TransitionManager.change_scene(self,"res://Scene/ending.tscn")
