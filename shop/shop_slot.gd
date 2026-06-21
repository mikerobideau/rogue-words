extends Control
class_name ShopSlot

signal purchased(slot: ShopSlot)

enum Type { RELIC, TOKEN, ITEM }

@onready var offer = $Offer
@onready var cost_label = $Footer/CostLabel
@onready var buy_button = $Footer/BuyButton
@onready var sold_label = $Footer/SoldLabel

var slot_type: Type
var relic_data: RelicData
var item_data: ItemData
var token_data: TokenData

var cost: int:
	set(v):
		cost = v
		if cost_label: cost_label.text = '$' + str(v)
		
var sold := false:
	set(v):
		sold = v
		if buy_button:
			buy_button.visible = !sold
		if sold_label:
			sold_label.visible = v
			
func _ready():
	sold_label.visible = false
	_update_buy_button()
	GameState.money_changed.connect(_on_money_changed)
			
func setup_relic(data: RelicData):
	slot_type = Type.RELIC
	relic_data = data
	cost = data.cost
	var scene = RelicFactory.create_scene(data)
	offer.add_child(scene)
	
func setup_item(data: ItemData):
	slot_type = Type.ITEM
	item_data = data
	cost = data.cost
	var scene = ItemFactory.create_scene(data)
	offer.add_child(scene)
	
func setup_token(data: TokenData):
	slot_type = Type.TOKEN
	token_data = data
	cost = data.cost
	var scene = TokenFactory.create_scene(data)
	offer.add_child(scene)

func _on_buy_button_pressed():
	if GameState.money >= cost:
		purchased.emit(self)
	
func _on_money_changed(v: int):
	_update_buy_button()
	
func _update_buy_button():
	if buy_button and not sold:
		buy_button.disabled = GameState.money < cost
