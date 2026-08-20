extends Node
class_name LoadoutFactoryGlobal

const LoadoutScene = preload("res://components/run/loadout/loadout.tscn")

func create_scene(data: LoadoutData) -> Loadout:
	var scene = LoadoutScene.instantiate()
	scene.data = data
	return scene

func load_all_loadouts() -> Array[LoadoutData]:
	print_debug('load all loadouts')
	return DataLoader.load_all("res://components/run/loadout/data/", LoadoutData)
