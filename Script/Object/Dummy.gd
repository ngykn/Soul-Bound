extends StaticBody2D

signal hit

func _on_hurtbox_hurt(entity) -> void:
	$AnimationPlayer.play("Knock_Off")
	emit_signal("hit")
