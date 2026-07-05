extends TextureButton
class_name RelicSlot

@export var relic_data: RelicData
var relic: Relic

func _on_pressed() -> void:
	_sell()
	
func _sell():
	GameState.money += relic_data.cost / 2
	GameState.remove_relic(relic_data)

func set_relic(data: RelicData):
	relic_data = data
	relic = RelicFactory.create_scene(data)
	add_child(relic)

func clear():
	for child in get_children():
		child.queue_free()
