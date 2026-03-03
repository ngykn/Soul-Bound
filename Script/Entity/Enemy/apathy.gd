class_name Apathy extends CharacterBody2D

signal wave_finished(count : int)

signal vulnerable
signal dead

@export var id : String

@export_category("Attack & Dialogue")
@export var dialogue :DialogueResource
@export var orb_scene : PackedScene
@export var attack_loop_count : int = 5
@export var attack_cooldown : float = 0.5

@onready var animation_player = $AnimationPlayer
@onready var attack_timer = $AttackTimer
@onready var hurtbox = $Hurtbox
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var attack_bar = $ProgressBar

var dramatic_attack_count : int

var is_vulnerable : bool = false
var is_dead : bool = false

func _ready():
	if GlobalReferences.killed_enemy.has(id):
		queue_free()

	if dialogue:
		dramatic_attack_count = dialogue.titles.size()
		attack_bar.max_value = dramatic_attack_count
		attack_bar.value = dramatic_attack_count

# =========================
# PUBLIC API
# =========================

func start_attack() -> void:
	attack_bar.visible = true
	_handle_attack()
	
func dramatic_attack() -> void:
	if !dialogue:
		printerr("dialogue : null")
		return

	var attack_finished_count = 0
	
	attack_bar.visible = true
	
	for d in dialogue.titles:
		GlobalFunction.costumize_show_dialogue(dialogue, d)
		await GlobalFunction.dialogue_ended
		await _handle_attack()
		attack_finished_count += 1
		await progress_tween(dramatic_attack_count - attack_finished_count)

	_handle_vulnerable()

# ========================
# INTERNAL
# ========================
func progress_tween(attack_left) -> void:
	var tween = create_tween()
	tween.tween_property(attack_bar, "value", attack_left, 0.2)
	await tween.finished

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
	hurtbox.hurt.connect(_die)

	collision_shape.set_deferred("disabled", true)
	sprite.modulate = Color('#ffffff6c')

	GlobalReferences.killed_enemy.append(id)
	emit_signal("vulnerable")

func _die(entity : Node2D) -> void:
	if is_vulnerable and !is_dead:
		animation_player.play("death")
		is_dead = true
		GlobalReferences.morality -= 10
		emit_signal("dead")
		attack_bar.visible = false
