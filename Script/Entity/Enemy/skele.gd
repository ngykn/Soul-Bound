extends BASIC_ENEMY

@onready var arm_aim :Node2D = $ArmAim
@onready var arm_swing :Node2D = $ArmAim/ArmSwing
@onready var sprite :Sprite2D = $Sprite2D
@onready var raycast :RayCast2D = $RayCast2D
@onready var life_bar = $ProgressBar
@onready var movement_animation :AnimationPlayer = $MovementAnimation
@onready var hurt_animation :AnimationPlayer= $HurtAnimation
@onready var attack_animation :AnimationPlayer = $AttackAnimation

enum states {
	IDLE,
	CHARGE,
	RETREAT,
	ATTACK
}

var current_state : states = states.IDLE
var lifebar_close_timer :float = 0.0 #max 1.5
var arm_aim_speed := 4.0
var min_target_pos : float = 15.0
var max_target_pos : float = 30.0

var _attacking : bool = false
var _dead : bool = false
var life : int = 3

	
func _physics_process(delta):
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

	if lifebar_close_timer == 0:
		life_bar.hide()
	else:
		life_bar.show()
		lifebar_close_timer = clampf(lifebar_close_timer - delta, 0, 1.5)

	raycast.enabled = true
	raycast.look_at(player.global_position)

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
	if life == 1 or player_distance() < min_target_pos:
		current_state = states.RETREAT
	elif player_is_in_position(min_target_pos,max_target_pos):
		current_state = states.ATTACK
	else:
		current_state = states.CHARGE

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

func attack() -> void:
	_attacking = true
	movement_animation.play("idle")
	sprite.flip_h = (player.global_position.x < global_position.x)
	attack_animation.play("attack")
	await attack_animation.animation_finished
	attack_animation.play("dagger_to_neutral")
	await attack_animation.animation_finished
	
	_attacking = false
	current_state = states.IDLE

func damage(entity : Node2D) -> void:
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
		
		await movement_animation.animation_finished
		await get_tree().create_timer(3).timeout
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
