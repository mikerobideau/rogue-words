extends Control
class_name ItemContainer

signal item_use_requested(slot: ItemSlot)

var selected_slot: ItemSlot = null

@onready var slots: Array[ItemSlot] = [$Items/Slot1, $Items/Slot2, $Items/Slot3]
@onready var label = $Label

func _ready():
	GameState.items_changed.connect(refresh_items)
	for slot in slots:
		slot.item_selected.connect(_on_slot_selected)
		slot.item_deselected.connect(_on_slot_deselected)
		slot.use_requested.connect(_on_slot_use_requested)
	refresh_items()

func _on_slot_use_requested(slot: ItemSlot) -> void:
	item_use_requested.emit(slot)

func _on_slot_selected(slot: ItemSlot):
	if selected_slot and selected_slot != slot: #single selection logic
		selected_slot.deselect()
	selected_slot = slot
	_update_label()
	
func _on_slot_deselected(slot: ItemSlot):
	if selected_slot == slot:
		selected_slot = null
	_update_label()
		
func _update_label():
	label.text = 'No item selected' if selected_slot == null else selected_slot.item_data.item_name + ' selected'
		
func deselect():
	selected_slot.deselect()

func refresh_items():
	for slot in slots:
		slot.clear()
	for i in slots.size():
		slots[i].deselect()
		if i < GameState.items.size():
			var item = GameState.items[i]
			slots[i].set_item(item)
