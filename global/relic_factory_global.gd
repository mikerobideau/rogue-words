extends Node
class_name RelicFactoryGlobal

var RelicScene = preload('res://components/relic/relic.tscn')

func create_scene(data: RelicData):
	var scene = RelicScene.instantiate()
	scene.data = data
	return scene

func load_all_relics() -> Array[RelicData]:
	return DataLoader.load_all("res://components/relic/data/", RelicData)
