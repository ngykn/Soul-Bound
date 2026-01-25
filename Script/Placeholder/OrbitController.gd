extends Node2D

@export var bullet_count := 8
@export var start_radius := 120.0
@export var shrink_speed := 14.0
@export var rotation_speed := 1.2
@export var lock_time := 1.2

var orbit_bullet_scene : PackedScene = preload("res://Object/orb_bullet.tscn")

var radius : float
var angle_offset := 0.0
var shrinking := false
var slots := []

func _ready():
	radius = start_radius

	# assign slots ONCE
	for i in bullet_count:
		var b = orbit_bullet_scene.instantiate()
		b.slot_index = i
		b.set_to_bullet_variation("empty")
		add_child(b)
		slots.append(b)

	global_position = get_tree().get_first_node_in_group("player").global_position
	await get_tree().create_timer(lock_time).timeout
	shrinking = true

func _process(delta):
	angle_offset += rotation_speed * delta

	if shrinking:
		radius -= shrink_speed * delta
		if radius <= 0:
			queue_free()

	update_bullets()

func update_bullets():
	var step := TAU / bullet_count
	for b in slots:
		if not is_instance_valid(b):
			continue

		var angle = angle_offset + step * b.slot_index
		b.global_position = global_position + Vector2(
			cos(angle),
			sin(angle)
		) * radius
