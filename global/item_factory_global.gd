extends Node
class_name ItemFactoryGlobal

var ItemScene = preload("res://components/item/item.tscn")

func create_scene(data: ItemData):
	var scene = ItemScene.instantiate()
	scene.data = data
	return scene
	
func load_all_items() -> Array[ItemData]:
	return DataLoader.load_all("res://components/item/data/", ItemData)
