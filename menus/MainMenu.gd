extends Node

var selections = ['Gameplay', 'Options', 'Quit']
var sel_positions
var sel_idx = 0



func move_selector():
	$Selector.rect_global_position = sel_positions[sel_idx]
	$Selector.rect_global_position.x -= 10
	$Selector.rect_size.y = $MarginContainer/MenuOptions/Gameplay.rect_size.y

func _ready():	
	var dir = Directory.new()
	if not dir.dir_exists('user://profiles'):
		dir.make_dir('user://profiles')
	sel_positions = [$MarginContainer/MenuOptions/Gameplay.rect_global_position
		, $MarginContainer/MenuOptions/Options.rect_global_position
		, $MarginContainer/MenuOptions/Quit.rect_global_position
		]
	move_selector()

func _process(delta):
	get_input()
	

func get_input():
	if Input.is_action_just_pressed('ui_right'):
		sel_idx = (sel_idx + 1) % len(selections)
	if Input.is_action_just_pressed('ui_left'):
		sel_idx = (sel_idx - 1) % len(selections)
	if Input.is_action_just_pressed('ui_down'):
		sel_idx = (sel_idx + 1) % len(selections)
	if Input.is_action_just_pressed('ui_up'):
		sel_idx = (sel_idx - 1) % len(selections)
	if Input.is_action_just_pressed('ui_cancel'):
		sel_idx = 2
	if Input.is_action_just_pressed('ui_accept'):
		if selections[sel_idx] == 'Quit':
			get_tree().quit()
		if selections[sel_idx] == 'Gameplay':
			get_tree().change_scene('res://menus/SelectProfile.tscn') 
	move_selector()