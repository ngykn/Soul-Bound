class_name UI extends Control

@onready var player_life : float = GlobalManager.player_life
@onready var life_bar : TextureProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/Health/TextureProgressBar
@onready var inventory = $CanvasLayer/Inventory
@onready var main_objectives = $CanvasLayer/MarginContainer/VBoxContainer/MainObjectives
@onready var menu = $CanvasLayer/MarginContainer/Pause
@onready var confirmation_dialog : ConfirmationDialog = $CanvasLayer/ConfirmationDialog


func _ready():
	get_tree().set_auto_accept_quit(false)
	confirmation_dialog.canceled.connect(cancel_confirmation_dialog)
	confirmation_dialog.confirmed.connect(quit_game)
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		show_confimation_dialog()

func _unhandled_key_input(event):
	if event.is_action_pressed("inventory"):
		show_inventory()
	
	if event.is_action_pressed("menu"):
		menu.pause()

func _process(delta):
	GlobalManager.player_life = clamp(GlobalManager.player_life,0,100)
	life_bar.value = GlobalManager.player_life

func show_inventory() -> void:
	inventory.visible = not inventory.visible

func show_confimation_dialog() -> void:
	confirmation_dialog.show()
	get_tree().paused = true

func cancel_confirmation_dialog() -> void:
	get_tree().paused = false

func quit_game() -> void:
	get_tree().quit()
