extends Scene

@onready var guard = $NPC/Guard
@onready var exit_point_2 :ChunkExit = $ExitPoint/ExitPoint2

var _have_orb : = false

func _ready():
	super._ready()
	if NpcManager.met_npcs.has("Aren"):
		exit_point_2.set_collision_disabled(false)
		guard.queue_free()

func _on_important_npc_dialogue_ended():
	if is_instance_valid(guard):
		exit_point_2.set_collision_disabled(false)
		guard.queue_free()


func _on_button_pressed():
	$Window.visible = not $Window.visible


func _on_window_orb(value):
	_have_orb = value
	$CameraController/Firefly.visible = value
