extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func narration_one() -> void:
	await TransitionManager.text_animation_fade(
	[
	"Without determination, without hope",
	"humanity forgets how to feel."],
	5.0
	)
