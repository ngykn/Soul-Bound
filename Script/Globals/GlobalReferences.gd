extends Node

var inventory : Array[String] = []
var killed_enemy : Array[String]= []
var morality := 0
var map_sequence : int = 0
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

var objectives :Array[String]= []
var chest_placers := []
var empty_chest := []

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
 
var map_offset : Dictionary = {
	"Ashenway" : Vector2(2560,736),
	"Ashfen": Vector2(4288,736),
	"AshfenCave": Vector2(0,0),
	"Barrenland": Vector2(0,0),
	"CrueltyCave" : Vector2(0,0),
	"DespairCave" : Vector2(0,0),
	"Highland" : Vector2(0,0),
	"HighlandsCave" : Vector2(0,0),
	"Middlehaven" : Vector2(1152,1152),
	"Southfield" : Vector2(1152,2368),
	"Tutorial" : Vector2(0,0),
	"Westfield" : Vector2(0,1152)
}

var map_compass_sequence : Array = [
	Vector2(1224,200), Vector2(1600,432), Vector2(1664,432),
	Vector2(1994,648), Vector2(3200,1056), Vector2(4392,960),
	(map_offset["Middlehaven"] + Vector2(672,272)), (map_offset["Ashfen"] + Vector2(536,1008)),
	(map_offset["Ashfen"] + Vector2(1328,168)), (map_offset["Ashfen"] + Vector2(536,2728)),
	Vector2(877,160)
]

func _ready() -> void:
	randomize()
	for i in randi_range(1,3):
		chest_placers.append(randi_range(0,5))
