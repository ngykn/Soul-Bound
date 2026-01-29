extends Control

@onready var line_edit = $MarginContainer/VBoxContainer/LineEdit

var nickname = [
	"Noctis", "Virex", "Elyra",
	"Morvain", "Ashryn", "Zypher", "Kael", "Nyx",
	"Severin", "Luneth", "Vaelor", "Thren", "Ilyon",
	"Ravik", "Seraph", "Umbra", "Kairn", "Eris",
	"Solace", "Vesper", "Malrik", "Orin", "Zephra",
	"Caelum", "Nerith", "Bane", "Lyrix", "Obryn",
	"Pharos", "Sable", "Tyris", "Iskra", "Velion",
	"Draven", "Eon", "Caligo", "Myrr", "Astra",
	"Korvin", "Nox", "Halcyon", "Riven", "Echo",
	"Silas", "Vahl", "Lucen", "Kheir", "Anima",
	"Thanis", "Voidra", "Elowen", "Kairoth", "Nymera",
	"Zeraph", "Omen", "Aurel", "Grimm", "Soryn",
	"Vaelis", "Duskryn", "Ichor", "Xyra", "Mourn",
	"Rhael", "Veil", "Cryos", "Ashen", "Noema",
	"Zorin", "Pallor", "Elyon", "Hex", "Vaen",
	"Mortis", "Cairne", "Luxor", "Nyxel", "Wraith",
	"Obsidia", "Talon", "Umbriel", "Keres", "Feral",
	"Zephyris", "Dreyl", "Nihra", "Sunder", "Eclipse",
	"Ruin", "Vanta", "Lorien", "Grave", "Solis"
]

func _on_save_pressed():
	if line_edit.text == "":
		line_edit.placeholder_text = "Invalid Name"
	else:
		GlobalManager.player_name = line_edit.text
		
		TransitionManager.change_scene(self, "res://Scene/tutorial.tscn")
func _on_randomize_pressed():
	var full_name = ("%s_%s") % [nickname.pick_random(), randi_range(0,100)]
	line_edit.text = full_name
