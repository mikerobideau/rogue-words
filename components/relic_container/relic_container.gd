extends MarginContainer
class_name RelicContainer

@onready var relics = $Relics

func refresh_relics():
	for child in relics.get_children():
		child.queue_free()
	for relic in GameState.relics:
		relics.add_child(RelicFactory.create_scene(relic))

func get_relics() -> Array[Relic]:
	var scenes = [] as Array[Relic]
	for child in relics.get_children():
		var relic = child as Relic
		scenes.append(relic)
	return scenes
