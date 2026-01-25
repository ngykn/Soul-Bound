class_name SceneEntryPoint extends Marker2D

@export_category("Cardinal Direction")
@export_enum("north","east","south","west")
var face_on_spawn : String

@export_category("Camera Limit")
@export var left : int = -10000000
@export var top : int = -10000000
@export var right : int = 10000000
@export var bottom : int = 10000000

func get_limit_to_array() -> Array:
	return [left,top,right,bottom] 
