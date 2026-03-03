extends StaticBody2D

signal opened

@onready var sprite = $Sprite2D
@onready var label = $Coin/Label
@onready var animation_player = $AnimationPlayer

var _player_near : bool = false
var _empty : bool = false

func _ready():
	if _empty:
		sprite.frame = 1

func _unhandled_key_input(event):
	if !_player_near or _empty:
		return

	if event.is_action_pressed("interact"):
		var cV = randi_range(35,45)
		animation_player.play("open")
		
		label.text = "+$" + str(cV)
		GameState.coin += cV
		_empty = true
		emit_signal("opened")

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		_player_near = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		_player_near = false
