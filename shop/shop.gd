extends Control
class_name ShopScene

const SlotScene = preload("res://shop/shop_slot.tscn")
const PackContentScene = preload("res://screens/pack_content/pack_content.tscn")

const SLOT_COUNT = 6
const STARTING_REROLL_COST = 3
const REROLL_INCREMENT = 2
const OFFER_SLOT_CHANCE = 0.5

signal completed()

@onready var slots = $CenterContainer/Slots
@onready var continue_button = $Footer/FooterInner/Continue
@onready var reroll_label = $ButtonContainer/VBoxContainer/Reroll
@onready var sign = $ShopSign

var pack_content: PackContent
var reroll_cost: int:
	set(v):
		reroll_cost = v
		reroll_label.text = 'REROLL ($' + str(reroll_cost) + ')'

func _ready():
	reroll_cost = STARTING_REROLL_COST
	_populate_slots()
	sign.slide_in()

func _populate_slots():
	var available_packs := PackFactory.load_all_packs()
	for i in SLOT_COUNT:
		if randf() < OFFER_SLOT_CHANCE or available_packs.is_empty():
			_add_offer_slot()
		else:
			_add_pack_slot(available_packs)

func _add_pack_slot(available_packs: Array) -> void:
	var pack_data = Rarity.pick_weighted(available_packs)
	available_packs.erase(pack_data)
	var slot = SlotScene.instantiate()
	slots.add_child(slot)
	slot.setup_pack(pack_data)
	slot.purchased.connect(_on_slot_purchased)
	slot.slot_selected.connect(_on_slot_selected)

func _add_offer_slot() -> void:
	var offer := _random_offer()
	if offer == null:
		return
	var slot = SlotScene.instantiate()
	slots.add_child(slot)
	slot.setup_offer(offer)
	slot.purchased.connect(_on_slot_purchased)
	slot.slot_selected.connect(_on_slot_selected)

func _random_offer() -> OfferData:
	var types := [OfferData.Type.ITEM, OfferData.Type.TOKEN]
	var relic_pool := _available_relics()
	if not relic_pool.is_empty():
		types.append(OfferData.Type.RELIC)

	var offer := OfferData.new()
	offer.type = types.pick_random()
	match offer.type:
		OfferData.Type.RELIC:
			offer.relic_data = Rarity.pick_weighted(relic_pool)
		OfferData.Type.ITEM:
			offer.item_data = Rarity.pick_weighted(ItemFactory.load_all_items())
		OfferData.Type.TOKEN:
			offer.token_data = Rarity.pick_weighted(TokenFactory.load_all_tokens())
	return offer
	
func _available_relics() -> Array:
	var owned := GameState.relics.map(func(r): return r.relic_name)
	return RelicFactory.load_all_relics().filter(func(r): return r.relic_name not in owned)

func _on_slot_purchased(slot: ShopSlot):
	GameState.money -= slot.cost
	slot.sold = true
	match slot.slot_type:
		ShopSlot.Type.PACK:
			_open_pack(slot.pack)
		ShopSlot.Type.OFFER:
			slot.offer_data.grant()

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
	match offer_data.type:
		OfferData.Type.RELIC:
			GameState.add_relic(offer_data.relic_data)
		OfferData.Type.ITEM:
			GameState.add_item(offer_data.item_data)
		OfferData.Type.TOKEN:
			GameState.add_token(offer_data.token_data)

func _on_open_pack_completed():
	pack_content.queue_free()

func _on_exit_pressed() -> void:
	completed.emit()

func _on_reroll_pressed() -> void:
	if GameState.money < reroll_cost:
		return
	GameState.money -= reroll_cost
	Sound.play(Sound.SOUND_REROLL)
	reroll_cost += REROLL_INCREMENT
	for slot in slots.get_children():
		slot.queue_free()
	_populate_slots()
