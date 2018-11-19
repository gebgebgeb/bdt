extends Node2D

onready var GLOBALS = get_node("/root/globals")
const Utils = preload("res://Utils.gd")

export (PackedScene) var Bullet = preload("res://gameplay/Bullet.tscn")

var frame = 0
var row_count = 0
var active = false

# stage parameters
var min_speed 
var max_speed 
var delay 
var spacing 
var num_rows
var min_angle
var max_angle 
var min_b_scale
var max_b_scale
var burst_spacing
var burst_spacing_dur # frames spent in burst
var burst_spacing_ratio # ratio of frames out of burst to frames in burst
var bskip_hang # how long to hang on a skipped bullet index

func _ready():
	pass

func arange(start, end, num):
	var diff = (end - start)/num
	var out = []
	for i in range(num):
		out.append(start + i * diff)
	return out
	
func spawn_row():
	if min_angle > max_angle:
		max_angle += 2*PI
	var diff_angle = max_angle - min_angle
	var bullets_to_add = []
	for i in range(num_rows):
		var angle = rand_range(
			min_angle + i*diff_angle/num_rows
			, min_angle + (i+1)*diff_angle/num_rows
			)
		var norm_dir = Vector2(-sin(angle), cos(angle)).normalized()
		var row_dir = Vector2(norm_dir.y, -norm_dir.x)

		var adj_spacing
		if burst_spacing_ratio == 0: # no bursts
			adj_spacing = spacing * num_rows
		elif int(row_count/burst_spacing_dur)%burst_spacing_ratio == burst_spacing_ratio-1:
			adj_spacing = burst_spacing * num_rows
		else:
			adj_spacing = spacing * num_rows

		var play_rad = GLOBALS.PLAY_AREA_SIZE.length()/2
		var play_mid = GLOBALS.PLAY_AREA_POS + GLOBALS.PLAY_AREA_SIZE/2
		var row_mid = play_mid - norm_dir*play_rad + row_dir*rand_range(0, adj_spacing)
		var row_len = GLOBALS.PLAY_AREA_SIZE.length() + adj_spacing*3
		var num_bullets = int(row_len / adj_spacing)
		
		var row_start = row_mid - row_dir*row_len/2
		var row_end = row_mid + row_dir*row_len/2

		var xs = arange(row_start.x, row_end.x, num_bullets)
		var ys = arange(row_start.y, row_end.y, num_bullets)

		for bullet_idx in range(len(xs)):
			if bskip_hang != 0:
				if int(((bullet_idx+i)%len(xs))/bskip_hang) ==  int((row_count % len(xs))/bskip_hang) and i%3 == 0:
					continue
				if int(((len(xs)-bullet_idx-1+i)%len(xs))/bskip_hang) ==  int((row_count % len(xs))/bskip_hang) and i%3 == 1:
					continue
				if int(((bullet_idx+i)%len(xs))/bskip_hang) ==  int(((len(xs) - abs(len(xs)-row_count)) % len(xs))/bskip_hang) and i%3 == 2:
					continue
			var speed = rand_range(min_speed, max_speed)
			var scale = rand_range(min_b_scale, max_b_scale)
			var velocity = norm_dir*speed
			
			var bullet = Bullet.instance()
			bullet.scale = Vector2(scale, scale)
			bullet.spawn(velocity, Vector2(xs[bullet_idx], ys[bullet_idx]))
			bullet.z_index = 1
			bullets_to_add.append(bullet)
	bullets_to_add = Utils.shuffle_list(bullets_to_add)
	for bullet in bullets_to_add:
		add_child(bullet)
		bullet.add_to_group('bullets')

func _process(delta):
	frame += 1
	if not active:
		return
	if frame % delay == 0:
		spawn_row()
		row_count += 1



func _on_Player_hit():
	get_tree().call_group("bullets", "player_hit")
	active = false
	row_count = 0


func _on_Player_respawned():
	active = true
