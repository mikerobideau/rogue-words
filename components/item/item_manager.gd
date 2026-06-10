extends Node
class_name ItemManager

signal items_changed(items: Array[Item])

var ItemScene = preload("res://components/item/item.tscn")

var items: Array[Item] = []
var active_items: Array[Item] = []

func _ready():
	_load_all_items()
	
func _add(data: ItemData):
	var scene = ItemScene.instantiate()
	scene.data = data
	scene.played.connect(_on_item_played)
	items.append(scene)
	items_changed.emit()
	
func _on_item_played(item: Item):
	active_items.erase(item)
	items_changed.emit(active_items)
	
func _load_all_items():
	var base_path = "res://components/item/data"
	var dir = DirAccess.open(base_path)
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			_load_items_from(base_path + '/' + entry)
		elif entry.ends_with(".tres"):
			var item= load(base_path + '/' + entry)
			_add(item)
		entry = dir.get_next()
	for item in items:
		active_items.append(item)
		
func _load_items_from(path: String):
	var sub_dir = DirAccess.open(path)
	if sub_dir == null:
		return
	sub_dir.list_dir_begin()
	var file = sub_dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var item = load(path + '/' + file)
			_add(item)
		file = sub_dir.get_next()
