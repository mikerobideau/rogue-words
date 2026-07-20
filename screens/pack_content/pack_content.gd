extends Control
class_name PackContent

const OfferSlotScene = preload("res://shop/offer_slot.tscn")
const SEPARATION = 50

signal completed()

@export var pack_data: PackData

@onready var offers: Control = $CenterContainer/Offers
@onready var skip_button = $Footer/SkipButton

var pack: Pack

func _ready():
	await get_tree().create_timer(0.5).timeout
	pack = _create_pack()
	add_child(pack)
	await _play_open_sequence()
	await pack.animate_open()
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
		offers.add_child(offer_slot)
	
func _animate_offers():
	for offer_slot in offers.get_children():
		await offer_slot.flip_open(0.5)
		
func _on_skip_button_pressed() -> void:
	pass

func _create_pack() -> Pack:
	var pack_data = preload("res://components/pack/data/item/super_item_pack/super_item_pack.tres")
	var scene = PackFactory.create_scene(pack_data)
	scene.position = Vector2(0, 0)
	return scene
