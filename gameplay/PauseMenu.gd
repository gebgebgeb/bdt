extends Node2D

signal quitting
signal unpausing

var paused

func _ready():
	paused = false

func _process(delta):
	if paused:
		if Input.is_action_just_pressed('game_pause'):
			visible = false
			paused = false
			emit_signal('unpausing')
			get_tree().paused = false
		if Input.is_action_just_pressed('game_quit'):
			emit_signal('quitting')
	if get_tree().paused:
		OS.delay_msec(20)
		paused = true

func _on_StatTracker_done_saving():
	if paused:

		get_tree().paused = false
		get_tree().change_scene('res://menus/SelectCourse.tscn')
