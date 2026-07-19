extends Node
class_name PackFactoryGlobal

var PackScene = preload("res://components/pack/pack.tscn")

func create_scene(data: PackData):
	var scene = PackScene.instantiate()
	scene.data = data
	return scene

func load_all_packs() -> Array[PackData]:
	return DataLoader.load_all("res://components/pack/data/", PackData)
