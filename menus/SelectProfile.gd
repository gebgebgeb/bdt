extends Node

onready var GLOBALS = get_node("/root/globals")

var profiles = []
var sel_positions = []
var options = []
var sel_idx = 0
var frame_one = true

const Utils = preload("res://Utils.gd")

func move_selector():
	get_sel_positions()
	$Selector.rect_global_position = sel_positions[sel_idx]
	$Selector.rect_global_position.x -= 10
	$Selector.rect_size.y = $MarginContainer/ProfileOptions.get_child(0).rect_size.y
	
func get_sel_positions():
	sel_positions = []
	for child in $MarginContainer/ProfileOptions.get_children():
		sel_positions.append(child.rect_global_position)

func _ready():
	profiles = Utils.get_profiles()
	for profile in profiles:
		var username = profile['data']['username']
		var label = Label.new()
		label.text = username
		$MarginContainer/ProfileOptions.add_child(label)
		options.append(profile)
	var label = Label.new()
	label.text = 'Create new profile'
	$MarginContainer/ProfileOptions.add_child(label)	
	options.append({'data': null, 'fn': 'create new profile'})
	get_sel_positions()
	move_selector()

func _process(delta):
	if frame_one:
		frame_one = false
		return
	get_input()
	move_selector()

func get_input():
	if Input.is_action_just_pressed('ui_right'):
		sel_idx = (sel_idx + 1) % len(options)
	if Input.is_action_just_pressed('ui_left'):
		sel_idx = (sel_idx - 1) % len(options)
	if Input.is_action_just_pressed('ui_down'):
		sel_idx = (sel_idx + 1) % len(options)
	if Input.is_action_just_pressed('ui_up'):
		sel_idx = (sel_idx - 1) % len(options)
	if Input.is_action_just_pressed('ui_accept'):
		if options[sel_idx]['fn'] == 'create new profile':
			get_tree().change_scene('res://menus/CreateProfile.tscn')
		else:
			GLOBALS.profile = options[sel_idx]
			GLOBALS.profile['data']['first_play'] = true
			var cur_datetime = OS.get_datetime()
			for key in ['day', 'month', 'year']:
				if not 'last_boot_time' in GLOBALS.profile['data']:
					GLOBALS.profile['data']['last_boot_time'] = OS.get_datetime()
					GLOBALS.profile['data']['seconds_played_today'] = 0
				elif cur_datetime[key] != GLOBALS.profile['data']['last_boot_time'][key]:
					GLOBALS.profile['data']['seconds_played_today'] = 0
			get_tree().change_scene('res://menus/SelectCourse.tscn')
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().change_scene('res://menus/MainMenu.tscn') 
