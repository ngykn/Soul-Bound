extends Scene

@onready var guard = $NPC/Guard

@onready var exit_point = $ExitPoint/ExitPoint
@onready var exit_point_2 :ChunkExit = $ExitPoint/ExitPoint2
@onready var exit_point_3 = $ExitPoint/ExitPoint3
@onready var exit_point_4 :ChunkExit= $ExitPoint/ExitPoint4

var _have_orb : = false

func _ready():
	super._ready()
	if NpcManager.met_npcs.has("Aren"):
		exit_point.set_collision_disabled(false)
		exit_point_2.set_collision_disabled(false)
		exit_point_3.set_collision_disabled(false)
		exit_point_4.set_collision_disabled(false)
		guard.queue_free()

func _on_important_npc_dialogue_ended():
	if is_instance_valid(guard):
		exit_point_2.set_collision_disabled(false)
		exit_point_4.set_collision_disabled(false)
		guard.queue_free()
