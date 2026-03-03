extends EnemyBullet

func _ready():
	super._ready()
	rotation = direction.angle()
