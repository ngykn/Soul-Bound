extends Node

var inventory : Array[String] = []
var killed_enemy : Array[String]= []
var morality := 0
var inventory_items : Dictionary = {
	"Health" : [
			preload("res://Assets/UI/Item/HealthNormal.png"),
			preload("res://Assets/UI/Item/HealthPressed.png"),
			true
		],
	"Strength" : [
			preload("res://Assets/UI/Item/StrengthPotionPressed.png"),
			preload("res://Assets/UI/Item/HealthPressed.png"),
			true
		],
	"Boots" : [
			preload("res://Assets/UI/Item/BootsNormal.png"),
			preload("res://Assets/UI/Item/BootsPressed.png"),
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

var minimap_texture : Dictionary = {
	"Ashenway" : [preload("res://Assets/Minimap/Ashenway.png"), 0.1],
	"Ashfen": [preload("res://Assets/Minimap/Ashfen.png"),0.1],
	"AshfenCave": [preload("res://Assets/Minimap/AshfenCave.png"),0.3],
	"Barrenland": [preload("res://Assets/Minimap/Barrenland.png"),0.1],
	"CrueltyCave" : [preload("res://Assets/Minimap/CrueltyCave.png"),0.2],
	"DespairCave" : [preload("res://Assets/Minimap/DespairCave.png"),0.5],
	"Highland" : [preload("res://Assets/Minimap/Highland.png"),0.1],
	"HighlandsCave" : [preload("res://Assets/Minimap/HighlandsCave.png"),0.3],
	"Middlehaven" : [preload("res://Assets/Minimap/Middlehaven.png"),0.2],
	"Southfield" : [preload("res://Assets/Minimap/Southfield.png"),0.2],
	"Tutorial" : [preload("res://Assets/Minimap/Tutorial.png"),0.15],
	"Westfield" : [preload("res://Assets/Minimap/Westfield.png"),0.13]
}
