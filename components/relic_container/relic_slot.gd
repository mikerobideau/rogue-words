extends Control
class_name RelicSlot

@onready var slot = $Slot
@onready var relic_container = $RelicContainer
@onready var buttons = $Buttons
@onready var keep = $Buttons/Keep
@onready var sell = $Buttons/Sell

@export var relic_data: RelicData
var relic: Relic

func set_relic(data: RelicData) -> void:
	clear()
	relic_data = data
	if data:
		relic = RelicFactory.create_scene(data)
		relic_container.add_child(relic)
	_disable_buttons()
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

func _on_keep_pressed() -> void:
	_disable_buttons()

func _on_sell_pressed() -> void:
	_disable_buttons()
	GameState.money += relic_data.cost / 2
	GameState.remove_relic(relic_data)

func _on_slot_pressed() -> void:
	if relic_data:
		_enable_buttons()
	
func _enable_buttons():
	buttons.visible = true
	keep.mouse_filter = MOUSE_FILTER_STOP
	sell.mouse_filter = MOUSE_FILTER_STOP
	
func _disable_buttons():
	buttons.visible = false
	keep.mouse_filter = MOUSE_FILTER_IGNORE
	sell.mouse_filter = MOUSE_FILTER_IGNORE
