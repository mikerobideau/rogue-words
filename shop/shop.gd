extends Control
class_name Shop

var SlotScene = preload("res://shop/shop_slot.tscn")

signal completed()

@onready var slots = $Slots
@onready var continue_button = $Footer/FooterInner/Continue

const SLOT_COUNT = 3
const TYPE_WEIGHTS = {
	'relic': 1,
	'token': 0,
	'item': 1
}
	
func _ready():
	GameState.money = 99 #TODO: Test - remove
	_populate_slots()
	
func _populate_slots():
	var pool: Array = []
	var all_relics = RelicFactory.load_all_relics()
	var all_tokens = TokenFactory.create_starting_tokens()
	var all_items = ItemFactory.load_all_items()
	
	for relic in all_relics:
		for i in TYPE_WEIGHTS['relic']:
			pool.append({'type': 'relic', 'data': relic})
	for item in all_items:
		for i in TYPE_WEIGHTS['item']:
			pool.append({'type': 'item', 'data': item})
	for token in all_tokens:
		for i in TYPE_WEIGHTS['token']:
			pool.append({'type': 'token', 'data': token})
			
	pool.shuffle()
	var seen = []
	var picked = []
	for entry in pool:
		if entry['data'] not in seen:
			seen.append(entry['data'])
			picked.append(entry)
		if picked.size() >= SLOT_COUNT:
			break
			
	for entry in picked:
		var slot = SlotScene.instantiate()
		slots.add_child(slot)
		match entry['type']:
			'relic':
				slot.setup_relic(entry['data'])
			'item':
				slot.setup_item(entry['data'])
			'token':
				slot.setup_token(entry['data'])
		slot.purchased.connect(_on_slot_purchased)
		
func _on_slot_purchased(slot: ShopSlot):
	GameState.money -= slot.cost
	match slot.slot_type:
		ShopSlot.Type.RELIC:
			GameState.add_relic(slot.relic_data)
		ShopSlot.Type.ITEM:
			GameState.add_item(slot.item_data)
		ShopSlot.Type.TOKEN:
			GameState.add_token(slot.token_data)
	slot.sold = true
		
func _on_exit_pressed() -> void:
	completed.emit()	
