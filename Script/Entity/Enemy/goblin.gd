extends BASIC_ENEMY

enum states{
	IDLE,
	CHARGE,
	ATTACK,
	DEAD
}

var current_state : states = states.IDLE
var life : int = 2

func _physics_process(delta):
	if lifebar_close_timer == 0:
		life_bar.hide()
	else:
		life_bar.show()
		lifebar_close_timer = clampf(lifebar_close_timer - delta, 0, 1.5)

	if !player or _dead:
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
	
	raycast.enabled = true
	raycast.look_at(player.global_position)
	
	match current_state:
		states.IDLE:
			idle()
		states.CHARGE:
			charge()
		states.ATTACK:
			attack()
			
	move_and_slide()

func idle() -> void:
	velocity = Vector2.ZERO
	movement_animation.play("idle")
	if player_is_in_position(0,27):
		current_state = states.ATTACK
	else:
		current_state = states.CHARGE

func charge() -> void:
	if player_distance() > 27:
		movement_animation.play("run")
		sprite.flip_h = (player.global_position.x < global_position.x)
		velocity = move()
	else:
		current_state = states.IDLE
	
func attack() -> void:
	_attacking = true
	movement_animation.play("idle")
	sprite.flip_h = (player.global_position.x < global_position.x)
	attack_animation.play("swing")
	await attack_animation.animation_finished

	_attacking = false
	current_state = states.IDLE

func _on_hurtbox_hurt(entity) -> void:
	var damageP := 1
	if GlobalManager.strength:
		damageP = 3
	life = clamp(life - damageP,0,3)

	life_bar.value = life
	lifebar_close_timer = 1.5

	if life != 0:
		hurt_animation.play("hurt")
	else:
		_dead = true
		movement_animation.play("death")
		
		GameState.coin += 20
		effects(20)
		await movement_animation.animation_finished
		await get_tree().create_timer(3).timeout
		queue_free()
