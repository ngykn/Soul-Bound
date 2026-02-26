class_name UI extends Control

@onready var player_life : float = GlobalManager.player_life
@onready var life_bar : TextureProgressBar = $CanvasLayer/MarginContainer/VBoxContainer/Health/Panel2/MarginContainer/HBoxContainer/VBoxContainer/Health
@onready var armor = $CanvasLayer/MarginContainer/VBoxContainer/Health/Panel2/MarginContainer/HBoxContainer/VBoxContainer/Armor
@onready var inventory = $CanvasLayer/Inventory
@onready var main_objectives = $CanvasLayer/MarginContainer/VBoxContainer/MainObjectives
@onready var menu = $CanvasLayer/MarginContainer/Pause
@onready var confirmation_dialog : ConfirmationDialog = $CanvasLayer/ConfirmationDialog
@onready var minimap = $CanvasLayer/MarginContainer/Minimap/Panel/SubViewportContainer/SubViewport

#items
@onready var armor_icon = $CanvasLayer/MarginContainer/VBoxContainer/Items/Armor
@onready var boot_icon = $CanvasLayer/MarginContainer/VBoxContainer/Items/Boot
@onready var strength_icon = $CanvasLayer/MarginContainer/VBoxContainer/Items/Strength


#item quantity
@onready var coin = $CanvasLayer/MarginContainer/VBoxContainer/Items/Coin/Label
@onready var shield = $CanvasLayer/MarginContainer/VBoxContainer/Items/Shield/Label


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

	GlobalManager.armor = clamp(GlobalManager.armor,0,50)
	armor.value = GlobalManager.armor

	coin.text = str(GameState.coin)
	shield.text = str(GlobalManager.shield)
	
	if armor.value == 0: 
		armor_icon.hide()
	else:
		armor_icon.show()
		
	if GlobalManager.boots:
		boot_icon.show()
	else:
		boot_icon.hide()
	
	if GlobalManager.strength:
		strength_icon.show()
	else:
		strength_icon.hide()

func show_inventory() -> void:
	inventory.visible = not inventory.visible

func show_confimation_dialog() -> void:
	confirmation_dialog.show()
	get_tree().paused = true

func cancel_confirmation_dialog() -> void:
	get_tree().paused = false

func quit_game() -> void:
	get_tree().quit()

func _on_inventory_use(Item):
	if Item == "Health":
		GlobalManager.player_life = clamp(GlobalManager.player_life + 30, 0, 100)
	elif Item == "Strength":
		GlobalManager.strength = true
		GlobalManager.strength_timer()
	elif Item == "Boots":
		GlobalManager.boots = true
		GlobalManager.boots_timer()
