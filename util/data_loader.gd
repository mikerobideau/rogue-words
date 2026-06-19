extends RefCounted
class_name DataLoader

static func load_all(base_path: String, resource_class: Script) -> Array:
	var results := Array([], TYPE_OBJECT, 'Resource', resource_class)
	_load_all_from(base_path, results)
	return results
	
static func _load_all_from(path: String, results: Array) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			_load_all_from(path + '/' + entry, results)
		elif entry.ends_with(".tres"):
			results.append(load(path + '/' + entry))
		entry = dir.get_next()
	dir.list_dir_end()
