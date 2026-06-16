extends Node
class_name ItemFactoryGlobal

var ItemScene = preload("res://components/item/item.tscn")

func create_scene(data: ItemData):
	var scene = ItemScene.instantiate()
	scene.data = data
	return scene
	
func load_all_items() -> Array[ItemData]:
	var all_item_data = [] as Array[ItemData]
	var base_path = "res://components/item/data"
	var dir = DirAccess.open(base_path)
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			_load_items_from(base_path + '/' + entry, all_item_data)
		elif entry.ends_with(".tres"):
			var data = load(base_path + '/' + entry)
			all_item_data.append(data)
		entry = dir.get_next()
	return all_item_data

func _load_items_from(path: String, all_item_data: Array[ItemData]) -> Array[ItemData]:
	var sub_dir = DirAccess.open(path)
	if sub_dir == null:
		return all_item_data
	sub_dir.list_dir_begin()
	var file = sub_dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var data = load(path + '/' + file)
			all_item_data.append(data)
		file = sub_dir.get_next()
	return all_item_data
