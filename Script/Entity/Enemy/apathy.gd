class_name Apathy extends CharacterBody2D

signal vulnerable
signal wave_finished(count : int)

@export var id : String

@export_category("Attack & Dialogue")
@export var dialogue :DialogueResource
@export var orb_scene : PackedScene
@export var attack_loop_count : int = 5
@export var attack_cooldown : float = 0.5

@onready var attack_timer = $AttackTimer
@onready var collision_shape = $CollisionShape2D

var state : String = "idle"
var is_vulnerable : bool = false
@onready var sprite = $Sprite2D

func _ready():
	if GlobalReferences.killed_enemy.has(id):
		queue_free()

# =========================
# PUBLIC API
# =========================

func start_attack() -> void:
	_handle_attack()
	
func dramatic_attack() -> void:
	if !dialogue:
		printerr("dialogue : null")
		return

	for d in dialogue.titles: 
		GlobalFunction.costumize_show_dialogue(dialogue, d)
		await GlobalFunction.dialogue_ended
		await _handle_attack()

	_handle_vulnerable()

# ========================
# INTERNAL
# ========================

func _handle_attack() -> void:
	var attack_count := 0
	for i in attack_loop_count:
		attack_count += 1
		await _spawn_orb()

		emit_signal("wave_finished", attack_count)
		await get_tree().create_timer(attack_cooldown).timeout


func _spawn_orb():
	var current_orb = orb_scene.instantiate()
	current_orb.global_position = global_position
	current_orb.apathy = self
	get_parent().add_child(current_orb)
	await current_orb.desolve


func _handle_vulnerable() -> void:
	if is_vulnerable:
		return

	is_vulnerable = true
	collision_shape.set_deferred("disabled", true)
	sprite.modulate = Color('#ffffff77')
	GlobalReferences.killed_enemy.append(id)
	emit_signal("vulnerable")

func _die() -> void:
	queue_free()
