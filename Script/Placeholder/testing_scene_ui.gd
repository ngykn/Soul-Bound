extends Window

signal save(choosen_enemy : String)

var enemy := "Apathy"

@onready var rb = $MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Scene/RB

func _on_close_requested():
	get_tree().paused = false
	emit_signal("save", get_enemy())
	hide()


func get_enemy() -> String:
	for radio_button in rb.get_children():
		if radio_button.button_pressed and radio_button is CheckBox:
			return radio_button.text
	
	return "Apathy"
