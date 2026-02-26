class_name EnemyBullet extends CharacterBody2D

@export var speed := 260.0
@export var lifetime := 3.0

@export var reveal_distance := 120.0
@export var full_visible_distance := 50.0

@onready var collision = $CollisionShape2D
@onready var hitbox_collision = $Hitbox/CollisionShape2D
@onready var player : Player


enum Variation {
	NORMAL_BULLET,
	HOLLOW_BULLET,
	EMPTY_ORBIT
}

var slot_index := 0

var variation := Variation.NORMAL_BULLET

var direction := Vector2.ZERO

func _ready() -> void:
	player = get_tree().current_scene.player
	velocity = direction.normalized() * speed
	
	if variation == Variation.EMPTY_ORBIT:
		collision.set_deferred("disabled",true)
		$Hitbox/CollisionShape2D.set_deferred("disabled",true)
		await get_tree().process_frame
		$Hitbox/CollisionShape2D.set_deferred("disabled",false)
		return

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta) -> void:
	match variation:
		Variation.HOLLOW_BULLET:
			_hollow_echo(delta)
		Variation.EMPTY_ORBIT:
			return
	
	move_and_slide()
	if get_slide_collision_count() > 0:
		queue_free()

func set_to_bullet_variation(bullet_variation : String) -> void:
	match bullet_variation:
		"normal":
			variation = Variation.NORMAL_BULLET
		"hollow":
			variation = Variation.HOLLOW_BULLET
		"empty":
			variation = Variation.EMPTY_ORBIT
		_:
			variation = Variation.NORMAL_BULLET

func _hollow_echo(delta):
	if not player:
		return

	var dist := global_position.distance_to(player.global_position)

	if dist > reveal_distance:
		modulate.a = 0.0
	elif dist <= full_visible_distance:
		modulate.a = 1.0
	else:
		modulate.a = remap(
			dist,
			reveal_distance,
			full_visible_distance,
			0.0,
			1.0
		)
