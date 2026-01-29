extends Panel

signal use(Item : String)

@onready var slot_list = $MarginContainer/MarginContainer/VBoxContainer/Slots

func _ready():
	for i in slot_list.get_children():
		i.used_item.connect(_item_used)

	_update_arrangement()

func _update_inventory(item : String, arrange : bool = false) -> void:
	for slot in slot_list.get_children():
		if not slot.occupied:
			slot.update_item(item, arrange)
			break

func _update_arrangement() -> void:
	for item in slot_list.get_children():
		item._clear(false)
	
	for i in GlobalReferences.inventory:
		_update_inventory(i, true)

func _item_used(item) -> void:
	_update_arrangement()
	emit_signal("use", item)
