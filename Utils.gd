class ProfileSorter:
	static func sort(a, b):
		return a['fn'] < b['fn']
		
static func shuffle_list(list):
    var shuffledList = [] 
    var indexList = range(list.size())
    for i in range(list.size()):
        var x = randi()%indexList.size()
        shuffledList.append(list[indexList[x]])
        indexList.remove(x)
    return shuffledList

static func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var fn = dir.get_next()
        if fn == "":
            break
        elif not fn.begins_with("."):
            files.append(fn)

    dir.list_dir_end()

    return files
	
static func get_profiles():
	var profiles = []
	for fn in list_files_in_directory('user://profiles'):
		if not fn.ends_with('.json'):
			continue
		var user_profile = {}
		var full_fn = 'user://profiles/' + fn
		var file = File.new()
		file.open(full_fn, file.READ)
		var text = file.get_as_text()
		user_profile = JSON.parse(text).result
		file.close()
		profiles.append({'data':user_profile, 'fn':full_fn})
	profiles.sort_custom(ProfileSorter, 'sort')
	return profiles
	
	
static func dictreader(filename):
	var file = File.new()
	file.open(filename, file.READ)
	var out = []
	var headers = file.get_csv_line()
	while true:
		var line = file.get_csv_line()
		if line.size() < headers.size():
			break
		var dictline = {}
		for i in range(len(headers)):
			dictline[headers[i]] = line[i]
		out.append(dictline)
	return out
	
static func mod(a, b):
	var out = a % b
	while out < 0:
		out += b
	return out
	