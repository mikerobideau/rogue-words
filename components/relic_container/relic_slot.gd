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
	Tooltip.register(self, relic_data.description)
	relic = RelicFactory.create_scene(data)
	add_child(relic)

func clear():
	for child in get_children():
		child.queue_free()
	
func register_tooltip():
	print_debug('register tooltip')
	print_debug('has relic data: ' + str(relic_data != null))
	var default_text = 'Empty coupon slot'
	var text = relic_data.description if relic_data != null else default_text
	Tooltip.register(self, text)
