extends MarginContainer
class_name RelicContainer

@onready var relics = $Relics

func setup(active_relics: Array[RelicData]):
	for data in active_relics:
		var scene = RelicFactory.create_scene(data)
		relics.add_child(scene)

func get_relics() -> Array[Relic]:
	var scenes = [] as Array[Relic]
	for child in relics.get_children():
		var relic = child as Relic
		scenes.append(relic)
	return scenes
