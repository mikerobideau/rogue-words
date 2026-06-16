extends Node
class_name RelicFactoryGlobal

var RelicScene = preload('res://components/relic/relic.tscn')

func create_scene(data: RelicData):
	var scene = RelicScene.instantiate()
	scene.data = data
	return scene

func load_all_relics() -> Array[RelicData]:
	var all_relic_data = [] as Array[RelicData]
	var base_path = "res://components/relic/data"
	var dir = DirAccess.open(base_path)
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			_load_relics_from(base_path + '/' + entry, all_relic_data)
		elif entry.ends_with(".tres"):
			var data = load(base_path + '/' + entry)
			all_relic_data.append(data)
		entry = dir.get_next()
	return all_relic_data

func _load_relics_from(path: String, all_relic_data: Array[RelicData]) -> Array[RelicData]:
	var sub_dir = DirAccess.open(path)
	if sub_dir == null:
		return all_relic_data
	sub_dir.list_dir_begin()
	var file = sub_dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var data = load(path + '/' + file)
			all_relic_data.append(data)
		file = sub_dir.get_next()
	return all_relic_data
