extends Scene

@onready var dummy = $Dummy


@onready var tutorial_progress = $CanvasLayer/MarginContainer/VBoxContainer/TutorialProgress


enum tutorial_list {
	MOVEMENT,
	INTERACT,
	INVENTORY,
	ATTACK,
	END
}

var current_tutorial := tutorial_list.MOVEMENT

#Func Control
var w := 1
var a := 1
var s := 1
var d := 1

#Attack tutorial
var dummy_life := 5


func _ready():
	super._ready()
	
	#NPC
	$NPC/NormalNpc.dialogue_ended.connect(_interaction_tutorial)
	$NPC/NormalNpc2.dialogue_ended.connect(_interaction_tutorial)
	
	#Inventory & Attack
	dummy.hit.connect(_attack_tutorial)
	ui.inventory.use.connect(_inventory_tutorial)
	
	
	GameState.input_enabled = false
	await TransitionManager.scene_transition_finished
	camera.lock_at(player.global_position)
	await get_tree().create_timer(1).timeout
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/Tutorial.dialogue"))
	

func _process(delta):
		if current_tutorial == tutorial_list.MOVEMENT:
			_movement_tutorial(delta)

func _movement_tutorial(delta) -> void:
	if !current_tutorial == tutorial_list.MOVEMENT or !GameState.input_enabled:
		return

	if Input.is_action_pressed("ui_left"):
		a = clamp(a - delta, 0, 2)
	elif Input.is_action_pressed("ui_right"):
		d = clamp(d - delta, 0, 2)
	elif Input.is_action_pressed("ui_up"):
		w = clamp(w - delta, 0, 2)
	elif Input.is_action_pressed("ui_down"):
		s = clamp(s - delta, 0, 2)

	if (w + a + s + d) == 0:
		tween_progress(25)
		camera.follow(player)
		current_tutorial = tutorial_list.INTERACT


func _interaction_tutorial() -> void:
	if !current_tutorial == tutorial_list.INTERACT:
		return

	tween_progress(50)
	current_tutorial = tutorial_list.ATTACK


func _inventory_tutorial(item) -> void:
	if item != "Health":
		return

	tween_progress(70)
	current_tutorial = tutorial_list.ATTACK
	ui.show_inventory()
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/Tutorial.dialogue"),"second_trainer_interaction")


func _attack_tutorial() -> void:
	if !current_tutorial == tutorial_list.ATTACK:
		return

	dummy_life -= 1
	if dummy_life == 0:
		current_tutorial = tutorial_list.END
		tween_progress(100)
		_tutorial_finished()


func _tutorial_finished() -> void:
	GlobalFunction.costumize_show_dialogue(preload("res://Dialogue/Tutorial.dialogue"),"end")
	await GlobalFunction.dialogue_ended
	TransitionManager.change_scene(self,"res://Scene/barrenland.tscn")

func tween_progress(to : float) -> void:
	var tween = create_tween()
	
	tween.tween_property(tutorial_progress, "value",to, 0.5).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished


func _on_trainer_dialogue_ended():
	if current_tutorial == tutorial_list.INVENTORY:
		await get_tree().process_frame
		GameState.input_enabled = false
