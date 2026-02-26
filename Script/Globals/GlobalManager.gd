extends Node

var player_name : String = "Devika"
var player_life : float = 70.0
var armor : float = 50.0

var shield : int = 0

var strength : bool = false
var boots : bool = false

func boots_timer() -> void:
	await get_tree().create_timer(20).timeout
	boots = false

func strength_timer() -> void:
	await get_tree().create_timer(10).timeout
	strength = false
