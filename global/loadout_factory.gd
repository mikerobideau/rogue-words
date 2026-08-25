extends Node
class_name LoadoutFactoryGlobal

const LoadoutScene = preload("res://components/run/loadout/loadout.tscn")

func create_scene(data: LoadoutData) -> Loadout:
	var scene = LoadoutScene.instantiate()
	scene.data = data
	return scene

var _loadouts_cache: Array[LoadoutData] = []
var _loadouts_loaded := false

func load_all_loadouts() -> Array[LoadoutData]:
	if not _loadouts_loaded:
		_loadouts_cache = DataLoader.load_all("res://components/run/loadout/data/", LoadoutData)
		_loadouts_loaded = true
	return _loadouts_cache.duplicate()
