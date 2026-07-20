extends Control
class_name ShopScene

var SlotScene = preload("res://shop/shop_slot.tscn")

signal completed()
signal pack_purchased(pack: PackData)

@onready var slots = $CenterContainer/Slots
@onready var continue_button = $Footer/FooterInner/Continue

const SLOT_COUNT = 3

func _ready():
	_populate_slots()

func _populate_slots():
	var available := PackFactory.load_all_packs()
	var picked := []
	while picked.size() < SLOT_COUNT and not available.is_empty():
		var pack = Rarity.pick_weighted(available)
		available.erase(pack)
		picked.append(pack)
	for pack in picked:
		var slot = SlotScene.instantiate()
		slots.add_child(slot)
		slot.setup_pack(pack)
		slot.purchased.connect(_on_slot_purchased)
		slot.slot_selected.connect(_on_slot_selected)

func _on_slot_purchased(slot: ShopSlot):
	GameState.money -= slot.cost
	slot.sold = true
	pack_purchased.emit(slot.pack_data)

func _on_slot_selected(s: ShopSlot):
	for slot in slots.get_children():
		if slot != s:
			slot.selected = false

func _on_exit_pressed() -> void:
	completed.emit()
