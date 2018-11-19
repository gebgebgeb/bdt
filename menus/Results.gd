extends Node

onready var GLOBALS = get_node("/root/globals")

func _ready():
	$MarginContainer/ResultRows/CourseTitle/Value.text = GLOBALS.last_log_data['course']
	$MarginContainer/ResultRows/StageNumber/Value.text = str(GLOBALS.last_log_data['stage_idx'] + 1)
	var seconds_played = GLOBALS.last_log_data['seconds_played']
	$MarginContainer/ResultRows/TimeSpent/Value.text = "%02d : %02d" % [seconds_played/60, seconds_played%60]
	var runs = GLOBALS.last_log_data['runs']
	var course = GLOBALS.course['stages'][GLOBALS.last_log_data['stage_idx']]
	for run in runs:
		var vals_to_add = []
		vals_to_add.append(str(run['frames_alive']))
		vals_to_add.append('%.1f' % (100*float(run['frames_focused']) / float(run['frames_alive'])))
		if run['frames_alive'] > int(course['clear_threshold']):
			vals_to_add.append('X')
			if run['frames_focused'] == 0:
				vals_to_add.append('X')
			else:
				vals_to_add.append('-')
		else:
			vals_to_add.append('-')
			vals_to_add.append('-')
		if run['frames_alive'] > int(course['hard_clear_threshold']):
			vals_to_add.append('X')
			if run['frames_focused'] == 0:
				vals_to_add.append('X')
			else:
				vals_to_add.append('-')
		else:
			vals_to_add.append('-')
			vals_to_add.append('-')
		for val in vals_to_add:
			var new_label = Label.new()
			$MarginContainer/ResultRows/MarginContainer/RunRows.add_child(new_label)
			new_label.text = val
			new_label.align = new_label.ALIGN_RIGHT
	

func _process(delta):
	if Input.is_action_just_pressed('ui_accept') or Input.is_action_just_pressed('ui_cancel'):
		get_tree().change_scene('res://menus/SelectCourse.tscn')
