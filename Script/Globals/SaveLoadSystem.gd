extends Node

var DATA := {"Hatdog" : 123}
var password := "secret123"

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()

func get_data() -> Dictionary:
	return {}

func save_data() -> void:
	var path = "user://save.save"
	var save_data = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, password)
	if save_data:
		var json_string = JSON.stringify(DATA)
		save_data.store_line(json_string)
		save_data.close()
	
func load_game() -> void:
	pass
