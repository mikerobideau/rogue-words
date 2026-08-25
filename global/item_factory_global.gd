extends Node
class_name ItemFactoryGlobal

var ItemScene = preload("res://components/item/item.tscn")

func create_scene(data: ItemData):
	var scene = ItemScene.instantiate()
	scene.data = data
	return scene
	
var _items_cache: Array[ItemData] = []
var _items_loaded := false

func load_all_items() -> Array[ItemData]:
	if not _items_loaded:
		_items_cache = DataLoader.load_all("res://components/item/data/", ItemData)
		_items_loaded = true
	return _items_cache.duplicate()
