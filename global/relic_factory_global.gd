extends Node
class_name RelicFactoryGlobal

var RelicScene = preload('res://components/relic/relic.tscn')

func create_scene(data: RelicData):
	var scene = RelicScene.instantiate()
	scene.data = data
	return scene

var _relics_cache: Array[RelicData] = []
var _relics_loaded := false

func load_all_relics() -> Array[RelicData]:
	if not _relics_loaded:
		_relics_cache = DataLoader.load_all("res://components/relic/data/", RelicData)
		_relics_loaded = true
	return _relics_cache.duplicate()
