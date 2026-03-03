extends BASIC_ENEMY

const ARROW : PackedScene = preload("res://Object/arrow.tscn")

@onready var bullet_position = $ArmAim/BulletPosition


enum states{
	IDLE,
	CHARGE,
	RETREAT,
	ATTACK
}

var current_state : states = states.IDLE

var life : int = 3

var cool_down : float = 1.5
var min_target_pos : float = 100
var max_target_pos : float = 200

func _physics_process(delta) -> void:
	if lifebar_close_timer == 0:
		life_bar.hide()
	else:
		life_bar.show()
		lifebar_close_timer = clampf(lifebar_close_timer - delta, 0, 1.5)

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
		effects(40)
		await movement_animation.animation_finished
		await get_tree().create_timer(2).timeout
		queue_free()

