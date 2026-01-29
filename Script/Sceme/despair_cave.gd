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
	await TransitionManager.scene_transition_finished
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/despair.dialogue"),"pre_fight_despair")
	await GlobalFunction.dialogue_ended
	despair.active = true

func despair_defeated() -> void:
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/despair.dialogue"),"Hope")
	await GlobalFunction.dialogue_ended
	hope.queue_free()

func despair_vulnerable() -> void:
	hope.dialogue_id = preload("res://Dialogue/despair.dialogue")
	hope.dialogue_title = "spared_despair"
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/despair.dialogue"),"despair_vulnerable")
	
func end() -> void:
	TransitionManager.change_scene(self,"res://UI/main_menu.tscn")
