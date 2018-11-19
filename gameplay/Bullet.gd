extends KinematicBody2D

var velocity
var start_pos
onready var GLOBALS = get_node("/root/globals")


func _ready():
	pass

func spawn(vel, pos):
	position = pos
	start_pos = pos
	velocity = vel

func _process(delta):
	position = position + velocity
	if start_pos.distance_to(position) >= GLOBALS.PLAY_AREA_SIZE.length():
		queue_free()


func player_hit():
	queue_free()