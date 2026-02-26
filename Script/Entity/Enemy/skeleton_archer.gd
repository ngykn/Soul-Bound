extends BASIC_ENEMY

const ARROW : PackedScene = preload("res://Object/arrow.tscn")

@onready var arm_aim = $ArmAim
@onready var bullet_position = $ArmAim/BulletPosition

@onready var raycast = $RayCast2D
@onready var sprite = $Sprite2D
@onready var life_bar = $LifeBar
@onready var attack_animation = $AttackAnimation
@onready var hurt_animation = $HurtAnimation
@onready var movement_animation = $MovementAnimation

enum states{
	IDLE,
	CHARGE,
	RETREAT,
	ATTACK
}

var current_state : states = states.IDLE

var life : int = 3
var _dead : bool = false

var lifebar_close_timer :float = 0.0 #max 1.5
var cool_down : float = 1.5
var arm_aim_speed := 4.0
var min_target_pos : float = 100
var max_target_pos : float = 200
var _attacking := false

func _physics_process(delta) -> void:
	if !player or _dead:
		life_bar.hide()
		return

	if _attacking:
		_update_arm_aim(delta)
		return

	if !player_is_near():
		current_state = states.IDLE
		raycast.enabled = false
		return

	if raycast.is_colliding():
		current_state = states.IDLE

	if cool_down <= 1.5:
		cool_down = clamp(cool_down + delta, 0, 1.5)

	if lifebar_close_timer == 0:
		life_bar.hide()
	else:
		life_bar.show()
		lifebar_close_timer = clampf(lifebar_close_timer - delta, 0, 1.5)

	raycast.enabled = true
	_update_arm_aim(delta)
	raycast.target_position = (player.global_position - global_position)

	match current_state:
		states.IDLE:
			idle()
		states.CHARGE:
			charge()
		states.RETREAT:
			retreat()
		states.ATTACK:
			attack()

	move_and_slide()

func idle() -> void:
	velocity = Vector2.ZERO
	
	movement_animation.play("idle")
	
	if player_is_in_position(min_target_pos,max_target_pos):
		current_state = states.ATTACK
	elif player_distance() < min_target_pos: 
		current_state = states.RETREAT
	else:
		current_state = states.CHARGE

func attack() -> void:
	if !cool_down == 1.5:
		return

	_attacking = true
	sprite.flip_h = (player.global_position.x < global_position.x)
	attack_animation.play("shoot")
	await attack_animation.animation_finished
	_shoot()
	attack_animation.play("RESET")
	cool_down = 0.0
	
	current_state = states.IDLE
	_attacking = false

func charge() -> void:
	if player_distance() > max_target_pos:
		movement_animation.play("run")
		sprite.flip_h = (player.global_position.x < global_position.x)
		
		velocity = move()
	else:
		current_state = states.IDLE

func retreat() -> void:
	if player_distance() < min_target_pos or life == 1:
		movement_animation.play("run")
		sprite.flip_h = !(player.global_position.x < global_position.x)
		
		_tween_arm_to_neutral()
		
		velocity = ((player.global_position - global_position).normalized() * speed) * -1
	else:
		current_state = states.IDLE


func _shoot() -> void:
	var arrow = ARROW.instantiate()

	arrow.position = bullet_position.global_position
	arrow.direction = (player.global_position - global_position)

	get_tree().current_scene.add_child(arrow)

func _damage(entity) -> void:
	var damageP := 1
	if GlobalManager.strength:
		damageP = 3
	life = clamp(life - damageP,0,3)

	life_bar.value = life
	lifebar_close_timer = 1.5
	if life > 0:
		hurt_animation.play("hurt")
	else:
		_dead = true
		movement_animation.play("death")
		
		GameState.coin += 40
		
		await movement_animation.animation_finished
		await get_tree().create_timer(2).timeout
		queue_free()

func _update_arm_aim(delta: float) -> void:
	var target_angle = (
		(player.global_position - arm_aim.global_position)
	).angle()

	arm_aim.rotation = lerp_angle(
		arm_aim.rotation,
		target_angle,
		arm_aim_speed * delta
	)

func _tween_arm_to_neutral() -> void:
	var tween := create_tween()
	tween.tween_property(arm_aim, "rotation", 0.0, 0.3)
	await tween.finished
