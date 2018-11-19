extends Node

const Utils = preload("res://Utils.gd")
var profiles

func _ready():
	profiles = Utils.get_profiles()
	$MarginContainer/NameEntry/Error.visible_characters = 0

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_LineEdit_text_changed(new_text):

	var change = false
	for c in new_text:
		if not c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
			change = true
			break

	if change:
		var entrybox = $MarginContainer/NameEntry/NameEntry
		var cursor_pos = entrybox.caret_position
		new_text = new_text.to_upper()
		var out = ''
		for c in new_text:
			if c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
				out = out + c
		entrybox.text = out
		entrybox.caret_position = cursor_pos

func _on_LineEdit_text_entered(new_text):
	var highest_fn = 0
	for profile in profiles:
		var prof_num = profile['fn'].to_int()
		if prof_num > highest_fn:
			highest_fn = prof_num
		if profile['data']['username'] == new_text:
			var error_msg = $MarginContainer/NameEntry/Error
			error_msg.text = 'Error: username already taken!'
			error_msg.visible_characters = -1
			return
	
	var new_fn = str(highest_fn + 1) + '.json'
	var new_profile = {'username': new_text}
	
	var profile_file = File.new()
	profile_file.open("user://profiles/" + new_fn, profile_file.WRITE)
	profile_file.store_string(JSON.print(new_profile))
	profile_file.close()
	get_tree().change_scene('res://menus/SelectProfile.tscn') 