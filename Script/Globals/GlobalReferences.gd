extends Node

var inventory : Array[String] = ["Dash Ring"]
var killed_apathy : Array[String]= []

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
		]
}
