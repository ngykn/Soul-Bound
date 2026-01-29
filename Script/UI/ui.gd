class_name UI extends Control

@onready var player_life : float = GlobalManager.player_life
@onready var life_bar : TextureProgressBar = $CanvasLayer/MarginContainer/Health/TextureProgressBar
@onready var inventory = $CanvasLayer/Inventory

func _unhandled_key_input(event):
	if event.is_action_pressed("inventory"):
		show_inventory()

func _process(delta):
	GlobalManager.player_life = clamp(GlobalManager.player_life,0,100)
	life_bar.value = GlobalManager.player_life

func show_inventory() -> void:
	inventory.visible = not inventory.visible
