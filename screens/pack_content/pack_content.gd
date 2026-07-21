extends Control
class_name PackContent

signal completed()
signal offer_picked(data: OfferData)

const OfferSlotScene = preload("res://shop/offer_slot.tscn")
const SEPARATION = 50
const OFFER_COLUMNS = 3
const OFFER_SLOT_SIZE = 450

@onready var background = $Background
@onready var offers: Control = $Body/Offers
@onready var skip_button = $Bottom/Center/SkipButton

var pack: Pack:
	set(v):
		pack = v
		pack_data = v.data
var pack_data: PackData
var num_picks_made = 0

func _ready():
	offers.custom_minimum_size.x = OFFER_COLUMNS * OFFER_SLOT_SIZE + (OFFER_COLUMNS - 1) * SEPARATION
	background.modulate.a = 0.0
		
func play():
	_fade_in_background()
	await _play_open_sequence()
	await pack.animate_open()
	pack.queue_free()
	_create_offers()
	_animate_offers()
	
func _fade_in_background():
	var t = create_tween()
	t.tween_property(background, "modulate:a", 1.0, 0.3)
	
func _play_open_sequence():
	var center = size / 2 - (pack.size / 2)
	
	#move pack to center
	var move = create_tween().set_parallel(true)
	move.tween_property(pack, 'position', center, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await move.finished
	
func _create_offers():
	pack.data.offers = PackFactory.generate_offers(pack.data)
	for offer_data in pack.data.offers:
		var offer_slot = OfferSlotScene.instantiate()
		offer_slot.data = offer_data
		offer_slot.picked.connect(_on_offer_picked)
		offers.add_child(offer_slot)
		
func _on_offer_picked(data: OfferData):
	num_picks_made += 1
	if num_picks_made >= pack_data.num_picks:
		_close()
	offer_picked.emit(data)
	
func _animate_offers():
	for offer_slot in offers.get_children():
		await offer_slot.flip_open(0.3)
		offer_slot.is_selectable = true
		
func _on_skip_button_pressed() -> void:
	_close()
	
func _close():
	completed.emit()
