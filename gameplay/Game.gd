extends Node2D

onready var GLOBALS = get_node("/root/globals")


func _ready():
	get_tree().set_auto_accept_quit(false)
	randomize()
	$PlayArea/PlayAreaHitbox.global_position = GLOBALS.PLAY_AREA_POS
	$PlayArea/PlayAreaHitbox.shape.extents = GLOBALS.PLAY_AREA_SIZE / 2
	$PlayArea/PlayAreaBG.rect_position = Vector2(30,30)
	$PlayArea/PlayAreaBG.rect_size = GLOBALS.PLAY_AREA_SIZE
	$PauseMenu.visible = false
	
	var stage = GLOBALS.course['stages'][GLOBALS.stage_idx]
	$Stage.min_speed = float(stage['min_speed'])
	$Stage.max_speed = float(stage['max_speed'])
	$Stage.delay = int(stage['delay'])
	$Stage.spacing = float(stage['spacing'])
	$Stage.num_rows = int(stage['num_rows'])
	$Stage.min_angle = float(stage['min_angle'])
	$Stage.max_angle = float(stage['max_angle'])
	$Stage.min_b_scale = float(stage['min_b_scale'])
	$Stage.max_b_scale = float(stage['max_b_scale'])
	$Stage.burst_spacing = float(stage['burst_spacing'])
	$Stage.burst_spacing_dur = int(stage['burst_spacing_dur'])
	$Stage.burst_spacing_ratio = int(stage['burst_spacing_ratio'])
	$Stage.bskip_hang = int(stage['bskip_hang'])
	
	$Player.spawn()
	$StatTracker.frames_alive = 0

func _process(delta):
	pass
	

func _on_Player_paused():
	$PauseMenu.visible = true
	$Player.visible = false
	$Stage.visible = false
	get_tree().paused = true


func _on_PauseMenu_unpausing():
	$Player.visible = true
	$Stage.visible = true
