class_name Door extends Area2D

var _can_enter := false

func _on_body_entered(body):
	if body.is_in_group("player"):
		_can_enter = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		_can_enter = false
