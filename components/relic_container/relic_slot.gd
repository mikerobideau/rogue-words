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
	register_tooltip()

func clear() -> void:
	relic_data = null
	if relic and is_instance_valid(relic):
		relic.queue_free()
	relic = null
	
func register_tooltip():
	var default_text = 'Empty coupon slot'
	var text = relic_data.description if relic_data != null else default_text
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
