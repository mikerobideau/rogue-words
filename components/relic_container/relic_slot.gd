extends Control
class_name RelicSlot

@onready var slot = $Slot
@onready var relic_container = $RelicContainer

@export var relic_data: RelicData
var relic: Relic

func set_relic(data: RelicData) -> void:
	clear()
	relic_data = data
	if data:
		relic = RelicFactory.create_scene(data)
		relic_container.add_child(relic)
		if not data.data_changed.is_connected(_refresh_tooltip):
			data.data_changed.connect(_refresh_tooltip)
	_refresh_tooltip()

func clear() -> void:
	if relic_data and relic_data.data_changed.is_connected(_refresh_tooltip):
		relic_data.data_changed.disconnect(_refresh_tooltip)   # avoid leak / stale 
	relic_data = null
	if relic and is_instance_valid(relic):
		relic.queue_free()
	relic = null
	
func _refresh_tooltip():
	var default_text = 'Empty coupon slot'
	var text: String
	if relic_data:
		var scaling_text = ' (currently '  + str(relic.data.scaling_value) + ')' if relic.data.is_scaling else ''
		text = relic_data.description + scaling_text
	else:
		text = default_text
	Tooltip.register(slot, text)
	
func _sell():
	GameState.money += relic_data.cost / 2
	GameState.remove_relic(relic_data)
	Tooltip.unregister(slot)

func _on_slot_pressed() -> void:
	if relic_data == null:
		return
	SlotMenu.open(slot, [
		{ "text": "Sell ($" + str(relic_data.cost / 2) + ")", "callback": _sell }
	])
