extends Node

var inventory : Array[String] = []
var killed_enemy : Array[String]= []

var inventory_items : Dictionary = {
	"Health" : [
		preload("res://Assets/UI/Item/HealthNormal.png"),
		preload("res://Assets/UI/Item/HealthPressed.png"),
		true
		],
	"Dash Ring":[
			preload("res://Assets/UI/Item/DashRingNormal.png"),
			preload("res://Assets/UI/Item/DashRingPressed.png"),
			false
		],
	"Emberlight" : [
		preload("res://Assets/UI/Item/GlowingNecklaceNormal.png"),
		preload("res://Assets/UI/Item/GlowingNecklacePressed.png"),
		false
		],
	"Sword" : [
		preload("res://Assets/UI/Item/SwordNormal.png"),
		preload("res://Assets/UI/Item/SwordPressed.png"),
		false
	]
}
