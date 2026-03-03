extends Marker2D

const CHEST : PackedScene = preload("res://Object/chest.tscn")

@export var id : int = 0

func _ready() -> void:
	if GlobalReferences.chest_placers.has(id):
		pchest(GlobalReferences.empty_chest.has(id))

func pchest(is_empty : bool) -> void:
	var chest_instance = CHEST.instantiate()
	chest_instance._empty = is_empty
	chest_instance.opened.connect(func(): GlobalReferences.empty_chest.append(id))
	add_child(chest_instance)
