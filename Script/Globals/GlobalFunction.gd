extends Node

signal dialogue_ended

const DefaultMass = 2.0
const DefaultMaxSpeed = 2.0


func costumize_show_dialogue(Dialogue : DialogueResource, title: String = "") -> void:
	GameState.input_enabled = false
	DialogueManager.show_dialogue_balloon(Dialogue,title)
	await DialogueManager.dialogue_ended
	emit_signal("dialogue_ended")
	GameState.input_enabled = true

func disable_layer(tilemap : TileMap, layer_name: String):
	for i in tilemap.get_layers_count():
		if tilemap.get_layer_name(i) == layer_name:
			tilemap.set_layer_enabled(i, false)
			return

static func follow(Velocity, GlobalPosition, TargetPosition, MaxSpeed = DefaultMass, Mass = DefaultMass):
	var DesiredVelocity = (TargetPosition - GlobalPosition).normalized() * MaxSpeed
	var Steering = (DesiredVelocity - Velocity) / Mass
	
	return Velocity + Steering
