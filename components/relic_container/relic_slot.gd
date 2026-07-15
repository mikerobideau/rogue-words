extends Control
class_name RelicSlot

@onready var slot = $Slot
@onready var relic_container = $RelicContainer

@export var relic_data: RelicData
var relic: Relic
var container: RelicContainer
var drag_active := false

func _ready():
	slot.mouse_entered.connect(_on_frame_mouse_entered)
	
func _notification(what: int):
	if what == NOTIFICATION_DRAG_END:
		drag_active = false

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
	
func _on_frame_mouse_entered() -> void:
	Sound.play(Sound.SOUND_MOUSEOVER)
	
func _refresh_tooltip():
	var default_text = 'Empty coupon slot'
	var text: String
	if relic_data:
		text = relic.data.get_tooltip_text()
	else:
		text = default_text
	Tooltip.register(slot, text)
	
func _sell():
	Sound.play(Sound.SOUND_MONEY)
	GameState.money += relic_data.cost / 2
	GameState.remove_relic(relic_data)
	Tooltip.unregister(slot)

func _on_slot_pressed() -> void:
	if drag_active or relic_data == null:
		return
	SlotMenu.open(slot, [
		{ "text": "Sell", "callback": _sell }
	])
	
func _get_drag_data(at_position):
	print("get_drag_data on ", name, " relic_data=", relic_data)
	if relic_data == null:
		return null
	drag_active = true
	var preview_relic = RelicFactory.create_scene(relic_data)
	preview_relic.position = -relic.size / 2.0
	preview_relic.modulate.a = 0.7
	var wrapper = Control.new()
	wrapper.add_child(preview_relic)
	set_drag_preview(wrapper)
	return {"type": "relic", "relic_data": relic_data}
	
func _can_drop_data(at_position, data) -> bool:
	return data is Dictionary and data.get("type") == "relic"
	
func _drop_data(at_position, data):
	container.move_relic(data["relic_data"], relic_data)
