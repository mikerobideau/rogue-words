extends Control
class_name ItemSlot

signal item_selected(slot: ItemSlot)
signal item_deselected(slot: ItemSlot)
signal use_requested(slot: ItemSlot)

@onready var slot = $Slot
@onready var item_container = $ItemContainer

const SLOT_SIZE = Vector2(106, 106)
		
var item: Item:
	set(v):
		item = v
		slot.disabled = item == null
var is_selected := false
var scale_tween: Tween

func _ready():
	slot.disabled = true
	size = SLOT_SIZE
	slot.toggle_mode = true
	slot.mouse_entered.connect(_on_frame_mouse_entered)

func _on_frame_mouse_entered() -> void:
	Sound.play(Sound.SOUND_MOUSEOVER)

func set_item(data: ItemData) -> void:
	clear()
	if data:
		item = ItemFactory.create_scene(data)
		item.set_size(Item.Size.SMALL)
		item.position = item_container.size / 2
		item_container.add_child(item)
	register_tooltip()

func clear() -> void:
	is_selected = false
	Tooltip.unregister(slot)
	if item and is_instance_valid(item):
		item.queue_free()
	item = null

func select():
	is_selected = true
	slot.button_pressed = true
	if item:
		_animate_selected(item, true)
	item_selected.emit(self)
	SlotMenu.open(slot, [
		{ "text": "Use",  "callback": _use },
		{ "text": "Sell", "callback": _sell },
	])

func _animate_selected(item: Item, selected: bool):
	if scale_tween:
		scale_tween.kill()
	var scale_tween = create_tween()
	var target = item.get_size(item.Size.MEDIUM) if selected else item.get_size(item.Size.SMALL)
	scale_tween.tween_property(item, "scale", target, 0.15)

func _use() -> void:
	use_requested.emit(self)
	
func deselect():
	is_selected = false
	slot.button_pressed = false
	if item:
		_animate_selected(item, false)
	item_deselected.emit(self)	
	SlotMenu.close()

func _keep():
	pass
	
func _sell():
	Sound.play(Sound.SOUND_MONEY_EARNED)
	GameState.money += round(item.data.cost / 2.0)
	GameState.remove_item(item.data)
	Tooltip.unregister(slot)

func animate_and_consume(target: Node2D):
	await item.float_to_target(target.global_position)
	deselect()
	item = null
	
func register_tooltip():
	var default_text = 'Empty item slot'
	var text = item.data.description if item.data else default_text
	Tooltip.register(slot, text)

func _on_slot_pressed() -> void:
	if item == null:
		slot.button_pressed = false
		return
	if slot.button_pressed:
		select()
	else:
		deselect()

func _on_slot_mouse_entered() -> void:
	pass # Replace with function body.
