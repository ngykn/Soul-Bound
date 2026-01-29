extends Scene

func _ready():
	super._ready()
	if GlobalReferences.killed_enemy.has("cruelty"):
		$Exit/CaveEntry2.to_cave_chunk = "res://Scene/despair_cave.tscn"
		$Exit/CaveEntry2.exit_point = ""
