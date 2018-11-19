extends Area2D

signal hit
signal respawned
signal paused


onready var GLOBALS = get_node("/root/globals")
export (int) var speed = 7
var cur_velocity
var start_pos
var active = true

func _ready():
	start_pos = Vector2(
		GLOBALS.PLAY_AREA_POS.x + GLOBALS.PLAY_AREA_SIZE.x/2
		, GLOBALS.PLAY_AREA_POS.y + GLOBALS.PLAY_AREA_SIZE.y*3/4
	)


func get_input():
	cur_velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		cur_velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		cur_velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		cur_velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		cur_velocity.y -= 1
	if cur_velocity.length() > 0:
		cur_velocity = cur_velocity.normalized() * speed
	if Input.is_action_pressed('focus_mode'):
		cur_velocity = cur_velocity/1.5
		$"hitbox/hbox sprite".visible = true
	else:
		$"hitbox/hbox sprite".visible = false
	if Input.is_action_just_pressed('game_pause'):
		emit_signal('paused')

func move():
	position += cur_velocity
	position.x = clamp(position.x, GLOBALS.PLAY_AREA_POS.x, GLOBALS.PLAY_AREA_POS.x + GLOBALS.PLAY_AREA_SIZE.x)
	position.y = clamp(position.y, GLOBALS.PLAY_AREA_POS.y, GLOBALS.PLAY_AREA_POS.y + GLOBALS.PLAY_AREA_SIZE.y)

func spawn():
	position = start_pos
	active=true
	$hitbox.disabled = false
	$"player sprite".visible = true
	$"hitbox/hbox sprite".visible = true
	emit_signal('respawned')

func _process(delta):
	if not active:
		return
	get_input()
	move() 

func _on_Player_body_entered(body):
	$hitbox.disabled = true
	$"player sprite".visible = false
	$"hitbox/hbox sprite".visible = false
	active = false
	$DeathParticles.emitting = true
	$DeadTimer.start()
	emit_signal("hit")

func _on_DeadTimer_timeout():
	spawn()
