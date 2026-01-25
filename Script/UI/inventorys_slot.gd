extends TextureRect

signal used_item

@onready var focus = $Focus
@onready var texture_button = $TextureButton

var occupied := false
var current_item : String = ""

var i : Array

func _ready():
	texture_button.pressed.connect(_use_item)

	mouse_entered.connect(_on_focus.bind(true))
	mouse_exited.connect(_on_focus.bind(false))

func update_item(item : String, arrange : bool = false) -> void:
	if !GlobalReferences.inventory_items.has(item) or occupied:
		printerr("Item Not Found: " + item)
		return

	if not arrange:
		GlobalReferences.inventory.append(item)

	texture_button.disabled = false
	i = GlobalReferences.inventory_items[item]
	

	occupied = true
	current_item = item
	texture_button.texture_normal = i[0]
	texture_button.texture_pressed = i[1]
	
func _use_item():
	if i.size() == 0:
		return

	if i[2]:
		_clear()
		emit_signal("used_item")

func _clear(erase : bool = true) -> void:
	if erase:
		GlobalReferences.inventory.erase(current_item)

	texture_button.disabled = true
	occupied = false
	i = []
	current_item = ""
	texture_button.texture_normal = null
	texture_button.texture_pressed = null

func _on_focus(value : bool):
	if value:
		focus.show()
	else:
		focus.hide()
