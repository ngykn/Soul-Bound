extends Scene

const player_path : PackedScene = preload("res://Entity/Player/player.tscn")
const apathy : PackedScene = preload("res://Entity/Enemy/Basic Enemy/apathy.tscn")
const cruelty : PackedScene = preload("res://Entity/Enemy/Boss/Cruelty.tscn")
const despair : PackedScene = preload("res://Entity/Enemy/Boss/despair.tscn")

var current_enemy = ""

func _ready():
	camera.lock_at($Marker2D.global_position)	
	
	var viewport_size := get_viewport_rect().size
	var zoom := camera.zoom
	var half_size := (viewport_size / zoom) * 0.5
	var cam_pos := camera.global_position



func _on_window_save(choosen_enemy):
	if choosen_enemy == current_enemy:
		return
		
	if player.is_dead:
		clear_player()
		
	current_enemy = choosen_enemy
	clear()
	match choosen_enemy:
		"Apathy":
			spawn_apathy()
		"Cruelty":
			spawn_cruelty()
		"Despair":
			spawn_despair()

func clear() -> void:
	var b = get_tree().get_nodes_in_group("bullet")
	var o = get_tree().get_nodes_in_group("orb")
	for i in $Enemy.get_children():
		i.queue_free()
		
	for bul in b:
		bul.queue_free()
	for i in o:
		i.queue_free()

func clear_player() -> void:
	player.queue_free()
	player = null
	GlobalManager.player_life = 100
	spawn_player()

func spawn_player() -> void:
	var p = player_path.instantiate()
	p.position = $PlayerSpawn.global_position
	add_child(p)
	player = p

func spawn_apathy() -> void:
	var a = apathy.instantiate()
	a.position = $EnemySpawn.global_position
	a.dialogue = preload("res://Dialogue/apathy.dialogue")
	$Enemy.add_child(a)
	
	await get_tree().create_timer(1.5).timeout
	a.dramatic_attack()

func spawn_cruelty() -> void:
	var c = cruelty.instantiate()
	c.position = $EnemySpawn.global_position
	c.min_x = $Min.global_position.x
	c.min_y = $Min.global_position.y
	c.max_x = $Max.global_position.x
	c.max_y = $Max.global_position.y
	$Enemy.add_child(c)
	c.start()
	
func spawn_despair() -> void:
	var d = despair.instantiate()
	d.position = $EnemySpawn.global_position
	$Enemy.add_child(d)

func _on_button_pressed():
	$Window.show()
	get_tree().paused = true
