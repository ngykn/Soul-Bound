class_name Hurtbox extends Area2D

signal hurt(entity : Node2D)

@export var enemy_groups : Array[String] = []
@export var _can_hurt : bool = true

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if !_can_hurt:
		return

	for group in enemy_groups:
		if area.is_in_group(group):
			var instance : Node2D = area.get_parent()
			emit_signal("hurt", instance)

			if instance.is_in_group("bullet"):
				instance.queue_free()
			return
