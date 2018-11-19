extends Node2D

onready var GLOBALS = get_node("/root/globals")

var NUM_DISP_CHOICES = 5
var midpoint = int(NUM_DISP_CHOICES/2)

var courses = []
var pattern_type_idx
var course_type
var course_type_idx
var menu_col_idx
var course_idx
var stage_idx

var profile_data
const Utils = preload("res://Utils.gd")
	
func load_courses():
	if course_type_idx == 0:
		course_type = 'density'
	else:
		course_type = 'speed'
	var pattern_type = str(pattern_type_idx+1)
	courses = GLOBALS.all_courses[pattern_type][course_type]

func initialize_course_textboxes():
	var course_container = $MarginContainer/HBoxContainer/Course/Courses
	for i in range(NUM_DISP_CHOICES):
		var course_row = HBoxContainer.new()
		course_container.add_child(course_row)
		var course_name = Label.new()
		course_row.add_child(course_name)

func initialize_stage_textboxes():
	var stage_container = $MarginContainer/HBoxContainer/Stage/Stages
	for i in range(NUM_DISP_CHOICES):
		var stage_row = HBoxContainer.new()
		stage_container.add_child(stage_row)
		var label = Label.new()
		stage_row.add_child(label)
		var cleared = Label.new()
		cleared.text = 'C'
		cleared.visible = false
		stage_row.add_child(cleared)
		var hard_cleared = Label.new()
		hard_cleared.text = 'HC'
		hard_cleared.visible = false
		stage_row.add_child(hard_cleared)
		var nf_cleared = Label.new()
		nf_cleared.text = 'NFC'
		nf_cleared.visible = false
		stage_row.add_child(nf_cleared)
		var nf_hard_cleared = Label.new()
		nf_hard_cleared.text = 'NFHC'
		nf_hard_cleared.visible = false
		stage_row.add_child(nf_hard_cleared)
		
func set_course_and_stage_idx():
	course_idx = min(len(courses)-1, course_idx)
	stage_idx = min(stage_idx, len(courses[course_idx]['stages'])-1)
	
func set_course_text():
	var course_container = $MarginContainer/HBoxContainer/Course/Courses
	load_courses()
	set_course_and_stage_idx()
	for i in range(NUM_DISP_CHOICES):
		var course_name = course_container.get_child(i).get_child(0)
		var course_num = Utils.mod(((i - midpoint) + course_idx), len(courses))
		course_name.text = courses[course_num]['metadata']['title']

func set_stage_text():
	set_course_and_stage_idx()
	var stage_container = $MarginContainer/HBoxContainer/Stage/Stages
	for i in range(NUM_DISP_CHOICES):
		var stage_row = stage_container.get_child(i)
		var stage_name = stage_row.get_child(0)
		var stage_num = Utils.mod(((i - midpoint) + stage_idx),len(courses[course_idx]['stages']))
		stage_name.text = "Stage " + str(stage_num+1)

		for clear_flag in [1,2,3,4]:
			stage_row.get_child(clear_flag).visible = false
		if 'clears' in GLOBALS.profile['data']:
			var course_title = courses[course_idx]['metadata']['title']
			if course_title in GLOBALS.profile['data']['clears']:
				var course_data = GLOBALS.profile['data']['clears'][course_title]
				if str(stage_num) in course_data:
					var stage_data = GLOBALS.profile['data']['clears'][course_title][str(stage_num)]
					stage_row.get_child(1).visible = stage_data['cleared']
					stage_row.get_child(2).visible = stage_data['hard_cleared']
					stage_row.get_child(3).visible = stage_data['nf_cleared']
					stage_row.get_child(4).visible = stage_data['nf_hard_cleared']

func set_text():
	set_course_text()
	set_stage_text()

func _ready():
	profile_data = GLOBALS.profile['data']
	if not 'last_played' in profile_data:
		profile_data['last_played'] = {
			'pattern_type_idx': 0
			, 'course_type_idx': 0
			, 'course_idx': 0
			, 'stage_idx': 0
			}
		profile_data['first_play'] = true
	var lp = profile_data['last_played']
	pattern_type_idx = int(lp['pattern_type_idx'])
	course_type_idx = int(lp['course_type_idx'])
	course_idx = int(lp['course_idx'])
	stage_idx = int(lp['stage_idx'])
	if profile_data['first_play']:
		menu_col_idx = 0
	else:
		menu_col_idx = 3
	initialize_course_textboxes()
	initialize_stage_textboxes()
	set_text()
	move_selectors()

func _process(delta):
	get_input()
	move_selectors()

func move_selectors():
	var pattern_type_nodes = $MarginContainer/HBoxContainer/PatternType/VBoxContainer
	var pattern_node = pattern_type_nodes.get_child(pattern_type_idx)
	$PatternTypeSelector.rect_global_position = pattern_node.rect_global_position
	$PatternTypeSelector.rect_global_position.x -= 10
	$PatternTypeSelector.rect_size.y = pattern_node.rect_size.y
	$PatternTypeSelector.visible = (menu_col_idx >= 0)

	var course_type_nodes = $MarginContainer/HBoxContainer/CourseType/VBoxContainer
	var course_node = course_type_nodes.get_child(course_type_idx)
	$CourseTypeSelector.rect_global_position = course_node.rect_global_position
	$CourseTypeSelector.rect_global_position.x -= 10
	$CourseTypeSelector.rect_size.y = course_node.rect_size.y
	$CourseTypeSelector.visible = (menu_col_idx >= 1)
	
	var course_labels = $MarginContainer/HBoxContainer/Course/Courses.get_children()
	$CourseSelector.rect_global_position = course_labels[midpoint].rect_global_position
	$CourseSelector.rect_global_position.x -= 10
	$CourseSelector.rect_size.y = course_labels[midpoint].rect_size.y
	$CourseSelector.visible = (menu_col_idx >= 2)
	
	var stage_labels = $MarginContainer/HBoxContainer/Stage/Stages.get_children()
	$StageSelector.rect_global_position = stage_labels[midpoint].rect_global_position
	$StageSelector.rect_global_position.x -= 10
	$StageSelector.rect_size.y = stage_labels[midpoint].rect_size.y
	$StageSelector.visible = (menu_col_idx >= 3)
	
	var current_col = $MarginContainer/HBoxContainer.get_child(menu_col_idx)
	$ColIndicator.rect_global_position = current_col.rect_global_position
	$ColIndicator.rect_size.x = current_col.rect_size.x
	$ColIndicator.rect_global_position.y -= 20

func get_input():
	if menu_col_idx == 0: # pattern type
		var pattern_type_nodes = $MarginContainer/HBoxContainer/PatternType/VBoxContainer
		if Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('ui_accept'):
			menu_col_idx += 1
		if Input.is_action_just_pressed('ui_down'):
			pattern_type_idx = Utils.mod((pattern_type_idx + 1), len(pattern_type_nodes.get_children()))
			set_text()
		if Input.is_action_just_pressed('ui_up'):
			pattern_type_idx = Utils.mod((pattern_type_idx - 1), len(pattern_type_nodes.get_children()))
			set_text()
		if Input.is_action_just_pressed('ui_cancel'):
			get_tree().change_scene('res://menus/MainMenu.tscn') 
	elif menu_col_idx == 1: # course type
		var course_type_nodes = $MarginContainer/HBoxContainer/CourseType/VBoxContainer
		if Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('ui_accept'):
			menu_col_idx += 1
			set_text()
		if (Input.is_action_just_pressed('ui_left') 
			or Input.is_action_just_pressed('ui_back') 
			or Input.is_action_just_pressed('ui_cancel')):
			menu_col_idx -= 1
		if Input.is_action_just_pressed('ui_down'):
			course_type_idx = Utils.mod((course_type_idx) + 1, len(course_type_nodes.get_children()))
			set_text()
		if Input.is_action_just_pressed('ui_up'):
			course_type_idx = Utils.mod((course_type_idx) - 1, len(course_type_nodes.get_children()))
			set_text()
	elif menu_col_idx == 2: # course
		if Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('ui_accept'):
			menu_col_idx += 1
			set_text()
		if Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_back'):
			menu_col_idx -= 1
			set_text()
		if Input.is_action_just_pressed('ui_down'):
			course_idx = Utils.mod((course_idx + 1), len(courses))
			set_text()
		if Input.is_action_just_pressed('ui_up'):
			course_idx = Utils.mod((course_idx - 1), len(courses))
			set_text()
		if Input.is_action_just_pressed('ui_cancel'):
			menu_col_idx = 0
			set_text()
	elif menu_col_idx == 3: # stage
		if Input.is_action_just_pressed('ui_accept'):
			GLOBALS.course = courses[course_idx]
			GLOBALS.stage_idx = stage_idx
			var lp = profile_data['last_played']
			lp['pattern_type_idx'] = pattern_type_idx
			lp['course_type_idx'] = course_type_idx
			lp['course_idx'] = course_idx
			lp['stage_idx'] = stage_idx
			get_tree().change_scene('res://gameplay/Game.tscn')
		if Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_back'):
			menu_col_idx -= 1
			set_text()
		if Input.is_action_just_pressed('ui_down'):
			stage_idx = Utils.mod((stage_idx + 1), len(courses[course_idx]['stages']))
			set_stage_text()
		if Input.is_action_just_pressed('ui_up'):
			stage_idx = Utils.mod((stage_idx - 1), len(courses[course_idx]['stages']))
			set_stage_text()
		if Input.is_action_just_pressed('ui_cancel'):
			menu_col_idx = 0
			set_text()