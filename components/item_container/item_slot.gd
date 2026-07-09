extends Control
class_name ItemSlot

signal item_selected(slot: ItemSlot)
signal item_deselected(slot: ItemSlot)
signal use_requested(slot: ItemSlot)

@onready var slot = $Slot
@onready var item_container = $ItemContainer

const SLOT_SIZE = Vector2(106, 106)

var item_data: ItemData
var item: Item
var is_selected := false

func set_item(data: ItemData) -> void:
	clear()
	item_data = data
	if data:
		item = ItemFactory.create_scene(data)
		item.position = slot.size / 2
		item_container.add_child(item)
	register_tooltip()

func clear() -> void:
	is_selected = false
	Tooltip.unregister(slot)
	if item and is_instance_valid(item):
		item.queue_free()
	item_data = null
	item = null

func _ready():
	size = SLOT_SIZE
	slot.toggle_mode = true

func select():
	is_selected = true
	slot.button_pressed = true
	if item:
		item.animate_selected(true)
	item_selected.emit(self)
	SlotMenu.open(slot, [
		{ "text": "Use",  "callback": _use },
		{ "text": "Sell ($" + str(item_data.cost / 2) + ")", "callback": _sell },
	])

func _use() -> void:
	use_requested.emit(self)
	
func deselect():
	is_selected = false
	slot.button_pressed = false
	if item:
		item.animate_selected(false)
	item_deselected.emit(self)	

func _keep():
	pass
	
func _sell():
	GameState.money += item_data.cost / 2
	GameState.remove_item(item_data)
	Tooltip.unregister(slot)

func animate_and_consume(target: Node2D):
	await item.float_to_target(target.global_position)
	deselect()
	item_data = null
	item = null
	
func register_tooltip():
	var default_text = 'Empty item slot'
	var text = item_data.description if item_data else default_text
	Tooltip.register(slot, text)

func _on_slot_pressed() -> void:
	if item_data == null:
		slot.button_pressed = false
		return
	if slot.button_pressed:
		select()
	else:
		deselect()
