extends Scene

@onready var cave_entry_2 : CaveEntry = $ExitPoint/CaveEntry2

func _ready():
	super._ready()
	if GlobalReferences.inventory.has("Emberlight"):
		player.player_light(true,10.0)
		cave_entry_2.exit_point = "Cave2"
	else:
		player.player_light(true,0.7)
