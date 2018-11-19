extends Node2D

signal done_saving

onready var GLOBALS = get_node("/root/globals")

const ALLOWED_DEATHS = 4

var frame = 0

var stage_data # user's stats for this stage
var profile_data # user's stats overall

var stage # info about the stage

var frames_alive = 0
var best_this_run = 0
var frames_focused_this_run = 0
var runs = []
# stats for this run, for logging
var cleared = false
var hard_cleared = false
var nf_cleared = false
var nf_hard_cleared = false
var seconds_played = 0
var num_deaths = 0

var cleared_before = false # user has ever cleared it

var waiting_for_respawn = false
var respawned = false
var active = true


func json_dump_with_backup(d, fn):
	var dir = Directory.new()
	
	var file = File.new()
	file.open(fn + '.bak', file.WRITE)
	file.store_string(JSON.print(d))
	file.close()
	
	dir.copy(fn+'.bak', fn)
	
func json_dump_to_log(d, fn):
	var dir = Directory.new()
	var file = File.new()
	if not dir.file_exists(fn):
		file.open(fn, file.WRITE)
		file.close()
	file.open(fn, file.READ_WRITE)
	file.seek_end()
	file.store_line(JSON.print(d))
	file.close()

func _ready():
	initialize_stage_data()
	profile_data['first_play'] = false
	profile_data['total_attempts'] += 1
	stage = GLOBALS.course['stages'][GLOBALS.stage_idx]
	
	cleared_before = stage_data['cleared']
	$StatBox/Clear/ProgressBar.max_value = int(stage['clear_threshold'])
	$StatBox/HardClear/ProgressBar.max_value = int(stage['hard_clear_threshold'])

func _process(delta):
	if respawned:
		if waiting_for_respawn:
			get_tree().change_scene('res://menus/Results.tscn')
		respawned = false
	if Input.is_action_just_pressed('ui_right'):
		profile_data['inputs']['right'] += 1
	if Input.is_action_just_pressed('ui_left'):
		profile_data['inputs']['left'] += 1
	if Input.is_action_just_pressed('ui_down'):
		profile_data['inputs']['down'] += 1
	if Input.is_action_just_pressed('ui_up'):
		profile_data['inputs']['up'] += 1
	if Input.is_action_just_pressed('focus_mode'):
		profile_data['inputs']['focus'] += 1
		frames_focused_this_run += 1
	if active:
		frame += 1
		frames_alive += 1
	if frames_alive == int(stage.clear_threshold): 
		if not cleared_before:
			stage_data['first_clear_date'] = OS.get_datetime()
		stage_data['last_clear_date'] = OS.get_datetime()
		stage_data['cleared'] = true
		cleared = true
		cleared_before = true
		if not frames_focused_this_run:
			nf_cleared = true
			stage_data['nf_cleared'] = true
	if frames_alive == int(stage.hard_clear_threshold):
		stage_data['hard_cleared'] = true
		hard_cleared = true
		if not frames_focused_this_run:
			nf_hard_cleared = true
			stage_data['nf_hard_cleared'] = true
	if frames_alive > best_this_run:
		best_this_run = frames_alive
	if best_this_run > stage_data['best_frames']:
		stage_data['best_frames'] = best_this_run
	
	$StatBox/LifeCounter/Value.text = str(ALLOWED_DEATHS-1-num_deaths)
	$StatBox/TimePlayed/Value.text = "%02d : %02d" % [seconds_played/60, seconds_played%60]
	$StatBox/FramesAliveCounter/Value.text = str(frames_alive)
	if runs:
		$StatBox/LastFramesAlive/Value.text = str(runs[-1]['frames_alive'])
	else:
		$StatBox/LastFramesAlive/Value.text = '--'
	$StatBox/BestThisRun/Value.text = str(best_this_run)
	$StatBox/BestEver/Value.text = str(stage_data['best_frames'])
	$StatBox/Clear/Value.visible = cleared
	$StatBox/HardClear/Value.visible = hard_cleared
	$StatBox/Clear/ProgressBar.value = frames_alive
	$StatBox/HardClear/ProgressBar.value = frames_alive

func initialize_stage_data():
	profile_data = GLOBALS.profile['data']
	if not 'clears' in profile_data:
		profile_data['clears'] = {}
	var course_title = GLOBALS.course['metadata']['title']
	if not course_title in profile_data['clears']:
		profile_data['clears'][course_title] = {}
	if not str(GLOBALS.stage_idx) in profile_data['clears'][course_title]:
		profile_data['clears'][course_title][str(GLOBALS.stage_idx)] = {}
	stage_data = profile_data['clears'][course_title][str(GLOBALS.stage_idx)]
	
	for key in ['total_attempts', 'total_deaths', 'seconds_played']:
		if not key in profile_data:
			profile_data[key] = 0
	if not 'inputs' in profile_data:
		profile_data['inputs'] = {}
	for key in ['left', 'right', 'up', 'down', 'focus']:
		if not key in profile_data['inputs']:
			profile_data['inputs'][key] = 0
		
	for key in ['total_seconds_played', 'total_deaths', 'best_frames'
		, 'seconds_before_first_clear', 'deaths_before_first_clear']:
		if not key in stage_data:
			stage_data[key] = 0
	for key in ['cleared', 'hard_cleared', 'nf_cleared', 'nf_hard_cleared']:
		if not key in stage_data:
			stage_data[key] = false
			
	
func save_data():	
	json_dump_with_backup(profile_data, GLOBALS.profile['fn'])
	var log_data = {
		'datetime': OS.get_datetime()
		, 'cleared': cleared
		, 'hard_cleared': hard_cleared
		, 'nf_cleared': nf_cleared
		, 'nf_hard_cleared': nf_hard_cleared
		, 'seconds_played': seconds_played
		, 'frames_played': frame
		, 'num_deaths': num_deaths
		, 'course': GLOBALS.course['metadata']['title']
		, 'stage_idx': GLOBALS.stage_idx
		, 'runs': runs
		}
	GLOBALS.last_log_data = log_data
	json_dump_to_log(log_data, GLOBALS.profile['fn'] + '.log')
	get_tree().set_auto_accept_quit(true)
	emit_signal('done_saving')
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_data()
		get_tree().quit()
		
func _on_PauseMenu_quitting():
	save_data()
	
func _on_SecondTimer_timeout():
	seconds_played += 1
	profile_data['seconds_played'] += 1
	stage_data['total_seconds_played'] += 1
	if not cleared_before:
		stage_data['seconds_before_first_clear'] += 1


func _on_Player_hit():
	active = false
	num_deaths += 1
	profile_data['total_deaths'] += 1
	stage_data['total_deaths'] += 1
	var run = {}
	run['frames_alive'] = frames_alive
	run['frames_focused'] = frames_focused_this_run
	runs.append(run)
	if not cleared_before:
		stage_data['deaths_before_first_clear'] += 1
	if num_deaths == ALLOWED_DEATHS:
		save_data()
		waiting_for_respawn = true


func _on_Player_respawned():
	frames_alive = 0
	frames_focused_this_run = 0
	respawned = true
	active = true
