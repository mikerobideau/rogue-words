extends Node
class_name SpaceFactoryGlobal

var SpaceScene = preload("res://components/space/space.tscn")

func create_random_scene() -> Space:
	var data = create_random_data()
	return create_scene(data)

func create_scene(data: SpaceData) -> Space:
	var scene = SpaceScene.instantiate()
	scene.data = data
	return scene

func create_random_data() -> SpaceData:
	var data = SpaceData.new()
	var enhanced_types = SpaceData.Type.values().filter(func(t): return t != SpaceData.Type.STANDARD)
	if randf() > 0.75:
		data.type = enhanced_types[randi() % enhanced_types.size()]
	else:
		data.type = SpaceData.Type.STANDARD
	return data
