class_name Hurtbox extends Area2D

signal hurt

@export var enemy_groups : Array[String] = []
@export var _can_hurt : bool = true

func _on_area_entered(area):
	if !_can_hurt:
		return
	
	for group in enemy_groups:
		if area.is_in_group(group):
			emit_signal("hurt")
			return
