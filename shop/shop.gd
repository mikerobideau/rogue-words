extends Control
class_name ShopScene

const SlotScene = preload("res://shop/shop_slot.tscn")
const PackContentScene = preload("res://screens/pack_content/pack_content.tscn")
const SLOT_COUNT = 3

signal completed()
signal pack_purchased(pack: PackData)

@onready var slots = $CenterContainer/Slots
@onready var continue_button = $Footer/FooterInner/Continue

var pack_content: PackContent

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
	_open_pack(slot.pack)

func _on_slot_selected(s: ShopSlot):
	for slot in slots.get_children():
		if slot != s:
			slot.selected = false

func _open_pack(pack: Pack):
	pack_content = PackContentScene.instantiate()
	pack_content.pack = pack
	add_child(pack_content)
	pack.reparent(pack_content)
	pack_content.play()
	pack_content.offer_picked.connect(_on_pack_offer_picked)
	pack_content.completed.connect(_on_open_pack_completed)
	
func _on_pack_offer_picked(offer_data: OfferData):
	print_debug('pack offer picked')
	match offer_data.type:
		OfferData.Type.RELIC:
			print_debug('adding relic')
			GameState.add_relic(offer_data.relic_data)
		OfferData.Type.ITEM:
			print_debug('adding item')
			GameState.add_item(offer_data.item_data)
		OfferData.Type.TOKEN:
			print_debug('adding token')
			GameState.add_token(offer_data.token_data)

func _on_open_pack_completed():
	pack_content.queue_free()

func _on_exit_pressed() -> void:
	completed.emit()
