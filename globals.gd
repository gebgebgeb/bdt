extends Node

const Utils = preload("res://Utils.gd")
const PLAY_AREA_SIZE = Vector2(780, 900)
const PLAY_AREA_POS = Vector2(30,30)

# this is an example dummy value for dev
var profile = {'data':
		{'username': 'DEV'
		, 'total_attempts': 20
		, 'total_deaths': 40
		, 'seconds_played': 20
		, 'seconds_played_today': 300
		, 'last_boot_time': {
			'year': 2018, 'month': 9, 'day': 11
			, 'dst': true, 'hour': 3, 'minute': 21, 'second': 39
			, 'weekday': 2
			}
		, 'inputs': {
			'left': 100
			, 'right': 300
			, 'up': 10
			, 'down': 30
			, 'focus': 0
			}
		, 'last_played': {
			'pattern_type_idx': 0
			, 'course_type_idx': 0
			, 'course_idx': 0
			, 'stage_idx': 0
			}
		, 'clears': {'Course 1': {
			'2': {
				'total_seconds_spent': 200
				, 'total_deaths': 30
				, 'best_frames': 30000
				, 'seconds_before_first_clear': 300
				, 'deaths_before_first_clear': 20
				, 'cleared': true
				, 'hard_cleared': false
				, 'nf_cleared': false
				, 'nf_hard_cleared': false
				, 'first_clear_date': {
					'year': 2018, 'month': 9, 'day': 11
					, 'dst': true, 'hour': 3, 'minute': 21, 'second': 39
					, 'weekday': 2
					}
				, 'last_clear_date': {
					'year': 2018, 'month': 9, 'day': 11
					, 'dst': true, 'hour': 3, 'minute': 21, 'second': 39
					, 'weekday': 2
					}
				}
			}}
		}
	, 'fn': 'user://profiles/999.json'
	}

var all_courses
var course = {
	'metadata':{'title': 'DEV'
		, 'pattern type': '1'
		, 'course type': 'density'
		}
	, 'stages':[
		{'min_speed' : 3
		, 'max_speed' : 6
		, 'delay' : 30
		, 'spacing' : 100
		, 'num_rows' : 4
		, 'min_angle' : -.15
		, 'max_angle' : .15
		, 'min_b_scale' : .15
		, 'max_b_scale' : .3
		, 'clear_threshold': 2000
		, 'hard_clear_threshold': 4000
		}]
	}

var last_log_data

# just an int
var stage_idx = 0

func _ready():
	load_courses()

class CourseSorter:
	static func sort(a, b):
		return a['metadata']['title'] < b['metadata']['title']	
	
func load_courses():
	all_courses = {}
	for pattern_type in ['1','2','3','4']:
		all_courses[pattern_type] = {}
		for course_type in ['density', 'speed']:
			var dir = Directory.new()
			var courses = []
			var parent_dir = 'res://courses/' + pattern_type + '/' + course_type + '/'
			for dirname in Utils.list_files_in_directory(parent_dir):
				var course_dir = parent_dir + dirname + '/'
				if not dir.open(course_dir) == OK:
					continue
				var metadata_file = File.new()
				metadata_file.open(course_dir + 'metadata.json', metadata_file.READ)
				var course_metadata = JSON.parse(metadata_file.get_as_text()).result
				metadata_file.close()
				
				var stage_data = Utils.dictreader(course_dir + 'stages.txt')
				if course_metadata and stage_data:
					courses.append({'metadata':course_metadata, 'stages':stage_data})
			courses.sort_custom(CourseSorter, 'sort')
			all_courses[pattern_type][course_type] = courses
