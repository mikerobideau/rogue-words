extends TextureButton
class_name ItemSlot

signal item_selected(slot: ItemSlot)
signal item_deselected(slot: ItemSlot)

const SLOT_SIZE = Vector2(106, 106)

var item_data: ItemData
var item: Item
var is_selected := false

func _ready():
	size = SLOT_SIZE
	toggle_mode = true

func _on_pressed():
	if item_data == null:
		button_pressed = false
		return
	if button_pressed:
		select()
	else:
		deselect()
	
func select():
	is_selected = true
	button_pressed = true
	if item:
		item.animate_selected(true)
	item_selected.emit(self)
	
func deselect():
	is_selected = false
	button_pressed = false
	if item:
		item.animate_selected(false)
	item_deselected.emit(self)	

func set_item(data: ItemData):
	item_data = data
	item = ItemFactory.create_scene(data)
	add_child(item)
	item.position = size / 2

func animate_and_consume(target: Node2D):
	await item.float_to_target(target.global_position)
	deselect()
	item_data = null
	item = null
	
func register_tooltip():
	var default_text = 'Empty item slot'
	var text = item_data.description if item_data else default_text
	Tooltip.register(self, text)
	
