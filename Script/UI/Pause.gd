extends Panel

@onready var bgm = $VBoxContainer/Music/Music
@onready var sfx = $VBoxContainer/SFX/SFX
@onready var bgm_slider = $VBoxContainer/Music/MusicSlider
@onready var sfx_slider = $VBoxContainer/SFX/SFXSlider
@onready var home_btn = $VBoxContainer/HBoxContainer3/Home
@onready var pause_btn = $VBoxContainer/HBoxContainer3/Pause
@onready var confirmation_dialog = $"../../ConfirmationDialog2"

var bgm_bus_idx = AudioServer.get_bus_index("BGM")
var sfx_bus_idx = AudioServer.get_bus_index("SFX")

func _ready():
	home_btn.pressed.connect(func(): confirmation_dialog.show())
	pause_btn.pressed.connect(unpaused)
	confirmation_dialog.confirmed.connect(go_to_home)

func pause() -> void:
	visible = not visible
	get_tree().paused = visible
	update_element()

func update_element() -> void:
	var bgm_value = db_to_linear(AudioServer.get_bus_volume_db(bgm_bus_idx))
	var sfx_value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_idx))

	bgm_slider.set_block_signals(true)
	bgm.set_block_signals(true)
	sfx_slider.set_block_signals(true)
	sfx.set_block_signals(true)

	bgm_slider.value = bgm_value
	sfx_slider.value = sfx_value
	
	bgm.button_pressed = !(bgm_value == 0)
	sfx.button_pressed = !(sfx_value == 0)

	bgm_slider.set_block_signals(false)
	bgm.set_block_signals(false)
	sfx_slider.set_block_signals(false)
	sfx.set_block_signals(false)

func _on_bgm_toggled(toggled_on):
	var value = 1.0 if toggled_on else 0.0

	bgm_slider.set_block_signals(true)
	bgm_slider.value = value
	bgm_slider.set_block_signals(false)

	AudioServer.set_bus_volume_db(bgm_bus_idx, linear_to_db(value))

func _on_sfx_toggled(toggled_on):
	var value = 1.0 if toggled_on else 0.0

	sfx_slider.set_block_signals(true)
	sfx_slider.value = value
	sfx_slider.set_block_signals(false)

	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bgm_bus_idx, linear_to_db(value))

func _on_music_slider_drag_ended(value_changed):
	var bgm_value = db_to_linear(AudioServer.get_bus_volume_db(bgm_bus_idx))

	bgm.set_block_signals(true)
	bgm.button_pressed = !(bgm_value == 0)
	bgm.set_block_signals(false)

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))

func _on_sfx_slider_drag_ended(value_changed):
	var sfx_value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_idx))

	sfx.set_block_signals(true)
	sfx.button_pressed = !(sfx_value == 0)
	sfx.set_block_signals(false)


func unpaused() -> void:
	get_tree().paused = false
	hide()

func go_to_home() -> void:
	unpaused()
	TransitionManager.change_scene(get_tree().current_scene, "res://UI/main_menu.tscn")
