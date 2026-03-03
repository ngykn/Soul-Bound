extends VBoxContainer

signal completed(objective : String)

@onready var objective_list = $Objectives
@onready var objective_sfx = $"../../../../ObjectiveSFX"

var objectives : Array[String] = []

func _ready():
	objectives = GlobalReferences.objectives
	_update_objective()

func add_objective(objective : String) -> void:
	objectives.append(objective)
	GlobalReferences.objectives = objectives
	_update_objective()

func completed_objective(objective : String) -> void:
	if objectives.has(objective):
		var ob_index = objectives.find(objective)
		var cobj = "[s]" + objective + "[/s]"
		objectives[ob_index] = cobj
		_update_objective()
		objective_sfx.play()
		emit_signal("completed")

		await get_tree().create_timer(2).timeout

		ob_index = objectives.find(cobj)
		objectives.pop_at(ob_index)
		_update_objective()


func _update_objective() -> void:
	objective_list.text = ""
	for o in objectives:
		objective_list.text = "    -" + o + "\n"
