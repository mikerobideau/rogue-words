extends Control
class_name ShopSlot

signal purchased(slot: PackSlot)
signal slot_selected(slot: PackSlot)

enum Type { PACK }

@onready var frame = $Frame
@onready var offer = $Frame/Offer
@onready var coin = $Coin
@onready var cost_label = $Coin/CostLabel
@onready var title_container = $Frame/TitleMargin
@onready var sold_sticker = $Sold

var slot_type: Type
var pack_data: PackData
var default_pos: Vector2
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
		
var position_tween: Tween
	
func _ready():
	default_pos = frame.position
			
func setup_pack(data: PackData):
	slot_type = Type.PACK
	pack_data = data
	cost = data.cost
	var scene = PackFactory.create_scene(data)
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
	offer.visible = false
	title_container.visible = false
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

func _on_frame_mouse_entered() -> void:
	Sound.play(Sound.SOUND_MOUSEOVER)
