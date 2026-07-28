extends Control
class_name ShopSlot

const PACK_SCALE = 0.5
const RELIC_SCALE = 0.75
const ITEM_SCALE = 1.5
const TOKEN_SCALE = 1.0

signal purchased(slot: ShopSlot)
signal slot_selected(slot: ShopSlot)

enum Type { PACK, OFFER }

@onready var frame = $Frame
@onready var offer = $Frame/Offer
@onready var coin = $Coin
@onready var cost_label = $Coin/CostLabel
@onready var title = $TitleContainer/Title
@onready var sold_sticker = $Sold

var pack: Pack
var slot_type: Type
var pack_data: PackData
var offer_data: OfferData
var default_pos: Vector2
var cost: int:
	set(v):
		cost = v
		if cost_label: cost_label.text = str(v)
var shake_tween: Tween
		
var sold := false:
	set(v):
		sold = v
		if v:
			sold_sticker.visible = true
			offer.visible = false
			frame.disabled = v
		
var position_tween: Tween
	
func _ready():
	default_pos = frame.position
	pivot_offset = size / 2
	frame.pivot_offset = frame.size / 2
			
func setup_pack(data: PackData):
	slot_type = Type.PACK
	pack_data = data
	cost = data.cost
	pack = PackFactory.create_scene(data)
	pack.scale = Vector2(PACK_SCALE, PACK_SCALE)
	title.text = data.pack_name
	Tooltip.register(frame, data.description)
	pack.position = offer.size / 2
	offer.add_child(pack)
	_add_offer(pack)
	
func setup_offer(data: OfferData):
	slot_type = Type.OFFER
	offer_data = data
	cost = data.cost
	title.text = data.get_title_text()
	Tooltip.register(frame, data.get_description())
	_add_offer(data.create_scene())

func _add_offer(scene: Node):
	offer.add_child(scene)
	if scene is Node2D:
		scene.position = offer.size / 2
	elif scene is Control:
		scene.position = (offer.size - scene.size) / 2
		
	if scene is Token:
		scene.scale = Vector2(TOKEN_SCALE, TOKEN_SCALE)
	if scene is Item:
		scene.scale = Vector2(ITEM_SCALE, ITEM_SCALE)
	if scene is Relic:
		scene.scale = Vector2(RELIC_SCALE, RELIC_SCALE)

func _on_frame_mouse_entered() -> void:
	if sold:
		return
	Sound.play(Sound.SOUND_MOUSEOVER)
	_shake_frame()

func _on_frame_pressed() -> void:
	if sold:
		return
	SlotMenu.open(frame, [
		{ "text": "Buy", "callback": _buy }
	])
	
func _buy() -> void:
	if GameState.money < cost:
		Sound.play(Sound.SOUND_DISABLED)
		ScorePopup.show('Insufficient funds!', self)
		return
		
	Sound.play(Sound.SOUND_PURCHASE)
	purchased.emit(self)
	coin.visible = false
	#frame.visible = false
	sold = true
	Tooltip.unregister(frame)
	
func _animate_selection():
	pass
	#if position_tween:
	#	position_tween.kill()
	#position_tween = create_tween()
	#var target_pos = default_pos + Vector2(0, -10) if selected else default_pos
	#var duration = 0.1 if selected else 0
	#position_tween.tween_property(frame, 'position', target_pos, duration)
	
func _shake_frame():
	if shake_tween:
		shake_tween.kill()
	shake_tween = create_tween()
	var angles = [4, -3, 2, -1, 0]
	for angle in angles:
		shake_tween.tween_property(frame, "rotation", deg_to_rad(angle), 0.07)
