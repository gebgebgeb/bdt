extends Node2D

var velocity
onready var GLOBALS = get_node("/root/globals")

var screensize

func _ready():
	screensize = get_viewport().size


func spawn(vel, pos):
	position = pos
	velocity = vel

func _process(delta):
	position = position + velocity
	if velocity.x < 0:
		if position.x < 0:
			position.x += screensize.x
	if velocity.x > 0:
		if position.x > screensize.x:
			position.x -= screensize.x