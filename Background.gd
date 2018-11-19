extends Node

export (PackedScene) var BGBullet = preload("res://BGBullet.tscn")
onready var GLOBALS = get_node("/root/globals")
const NUM_BULLETS = 5000
const MIN_SPEED = 2
const MAX_SPEED = 10

func _ready():
	var start_y
	var start_pos
	var velocity
	
	var screensize = get_viewport().size
	
	for i in range(NUM_BULLETS):
		start_y = rand_range(0, screensize.y)
		start_pos = Vector2(rand_range(0,1)*screensize.x, start_y)

		velocity = Vector2(-rand_range(MIN_SPEED, MAX_SPEED), 0)
		var bullet = BGBullet.instance()
		add_child(bullet)
		bullet.spawn(velocity, start_pos)