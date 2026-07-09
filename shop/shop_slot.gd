extends Control
class_name ShopSlot

signal purchased(slot: ShopSlot)

enum Type { RELIC, TOKEN, ITEM }

@onready var frame = $Frame
@onready var offer = $Frame/Offer
@onready var cost_label = $Coin/CostLabel
@onready var title_container = $Frame/TitleMargin
@onready var title = $Frame/TitleMargin/Title
@onready var coin = $Coin
@onready var buy_button = $BuyButton
@onready var sold_sticker = $Sold

var slot_type: Type
var relic_data: RelicData
var item_data: ItemData
var token_data: TokenData
var default_pos: Vector2
var description: String

var cost: int:
	set(v):
		cost = v
		if cost_label: cost_label.text = str(v)
		
var sold := false:
	set(v):
		sold = v
		if sold_sticker:
			sold_sticker.visible = v
		if frame:
			frame.disabled = v
			
var selected := false:
	set(v):
		selected = v
		_animate_selection()
		buy_button.visible = true if selected else false
		
var position_tween: Tween
	
func _ready():
	default_pos = frame.position
			
func setup_relic(data: RelicData):
	slot_type = Type.RELIC
	title.text = 'Coupon'
	relic_data = data
	Tooltip.register(frame, data.description)
	cost = data.cost
	var scene = RelicFactory.create_scene(data)
	scene.position = offer.size / 2
	scene.scale = Vector2(0.67, 0.67)
	_add_offer(scene)
	
func setup_item(data: ItemData):
	slot_type = Type.ITEM
	title.text = 'Item'
	item_data = data
	Tooltip.register(frame, data.description)
	cost = data.cost
	var scene = ItemFactory.create_scene(data)
	offer.add_child(scene)
	_add_offer(scene)
	
func setup_token(data: TokenData):
	slot_type = Type.TOKEN
	title.text = 'Token'
	token_data = data
	cost = data.cost
	var scene = TokenFactory.create_scene(data)
	Tooltip.register(frame, scene.get_tooltip_text())
	scene.position = offer.size / 2
	offer.add_child(scene)
	_add_offer(scene)

func _add_offer(scene: Node):
	offer.add_child(scene)
	if scene is Node2D:
		scene.position = offer.size / 2
	elif scene is Control:
		scene.position = (offer.size - scene.size) / 2

func _on_pressed() -> void:
	_toggle_selection()
	
func _toggle_selection():
	selected = !selected
	
func _animate_selection():
	if position_tween:
		position_tween.kill()
	position_tween = create_tween()
	var target_pos = default_pos + Vector2(0, -10) if selected else default_pos
	var duration = 0.1 if selected else 0
	position_tween.tween_property(frame, 'position', target_pos, duration)

func _on_frame_mouse_entered() -> void:
	Sound.play('token')

func _on_buy_pressed() -> void:
	if _inventory_full():
		ScorePopup.show('Inventory full!', self)
		return
	if GameState.money < cost:
		ScorePopup.show('Insufficient funds!', self)
		return
	Sound.play('purchase')
	purchased.emit(self)
	coin.visible = false
	offer.visible = false
	title_container.visible = false
	sold = true
	selected = false
	Tooltip.unregister(frame)
		
func _inventory_full():
	if relic_data != null:
		return GameState.relic_slots_available() < 1
	if item_data != null:
		return GameState.item_slots_available() < 1
	return false
