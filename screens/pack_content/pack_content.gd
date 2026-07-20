extends Control
class_name PackContent

signal completed()
signal offer_picked(data: OfferData)

const OfferSlotScene = preload("res://shop/offer_slot.tscn")
const SEPARATION = 50

@export var pack_data: PackData

@onready var offers: Control = $CenterContainer/Offers
@onready var skip_button = $Bottom/SkipButton

var pack: Pack
var num_picks_made = 0

func _ready():
	await get_tree().create_timer(0.5).timeout
	pack = _create_pack()
	add_child(pack)
	await _play_open_sequence()
	await pack.animate_open()
	pack.queue_free()
	_create_offers()
	_animate_offers()
	
func _play_open_sequence():
	var center = size / 2 - (pack.size / 2)
	
	#move pack to center
	var move = create_tween().set_parallel(true)
	move.tween_property(pack, 'position', center, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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
		completed.emit()
	offer_picked.emit(data)
	
func _animate_offers():
	for offer_slot in offers.get_children():
		await offer_slot.flip_open(0.5)
		offer_slot.is_selectable = true
		
func _on_skip_button_pressed() -> void:
	completed.emit()

func _create_pack() -> Pack:
	pack_data = preload("res://components/pack/data/item/super_item_pack/super_item_pack.tres")
	var scene = PackFactory.create_scene(pack_data)
	scene.position = Vector2(0, 0)
	return scene
