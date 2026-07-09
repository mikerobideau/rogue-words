extends Control
class_name Shop

var SlotScene = preload("res://shop/shop_slot.tscn")

signal completed()

@onready var slots = $Slots
@onready var continue_button = $Footer/FooterInner/Continue

const SLOT_COUNT = 6
const TYPE_WEIGHTS = {
	'relic': 1,
	'token': 1,
	'item': 1
}
	
func _ready():
	_populate_slots()
	
func _populate_slots():
	var owned_names := GameState.relics.map(func(r): return r.relic_name)
	var pools := {
		'relic': RelicFactory.load_all_relics().filter(func(r): return r.relic_name not in owned_names),
		'item':  ItemFactory.load_all_items(),
		'token': TokenFactory.create_starting_tokens(),
	}
	var picked := []
	var seen := []

	while picked.size() < SLOT_COUNT:
		# only consider types that still have an unseen option
		var available := TYPE_WEIGHTS.keys().filter(func(t):
			return pools[t].any(func(d): return d not in seen))
		if available.is_empty():
			break

		var type: String = _weighted_pick_type(available)
		var options = pools[type].filter(func(d): return d not in seen)
		var data = options[randi() % options.size()]

		seen.append(data)
		picked.append({ 'type': type, 'data': data })

	for entry in picked:
		var slot = SlotScene.instantiate()
		slots.add_child(slot)
		match entry['type']:
			'relic': slot.setup_relic(entry['data'])
			'item':  slot.setup_item(entry['data'])
			'token': slot.setup_token(entry['data'])
		slot.purchased.connect(_on_slot_purchased)

func _weighted_pick_type(types: Array) -> String:
	var total := 0
	for t in types:
		total += TYPE_WEIGHTS[t]
	var r := randi() % total
	for t in types:
		r -= TYPE_WEIGHTS[t]
		if r < 0:
			return t
	return types[0]

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
