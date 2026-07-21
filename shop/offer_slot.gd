extends Control
class_name OfferSlot

signal picked(data: OfferData)

enum Type { RELIC, TOKEN, ITEM }

const OFFER_SCALE := Vector2(1.0, 1.0)
const BACK_TEXTURE = preload("res://assets/sprites/slot/1x/slot_back.png")

@export var is_selectable := false

@onready var frame = $Frame
@onready var title_container = $Frame/TitleContainer
@onready var title = $Frame/TitleContainer/VBoxContainer/Title
@onready var rarity_label = $Frame/TitleContainer/VBoxContainer/Rarity
@onready var offer_container = $Frame/OfferMargin/Offer

var data: OfferData:
	set(v):
		data = v
		if is_node_ready():
			_refresh()
			
var default_pos: Vector2
var description: String
var is_picked := false
var scene: Node
var front_texture: Texture2D
var shake_tween: Tween

func _ready():
	title_container.visible = false
	pivot_offset = size / 2
	frame.pivot_offset = frame.size / 2
	scale = Vector2.ZERO
	front_texture = frame.texture_normal
	_set_face_down()
	_refresh()

func _on_frame_mouse_entered() -> void:
	if !is_selectable:
		return
	Sound.play(Sound.SOUND_MOUSEOVER)
	_shake_frame()

func _on_frame_pressed() -> void:
	if !is_selectable:
		return
	SlotMenu.open(frame, [
		{ "text": "Choose", "callback": _choose }
	])

func _set_face_down():
	frame.texture_normal = BACK_TEXTURE
	offer_container.visible = false

func _refresh() -> void:
	if data == null:
		return
	_clear_offer()
	title.text = data.get_title_text()
	rarity_label.text = data.get_rarity_label()
	Tooltip.register(frame, data.get_description())

	var scene := data.create_scene()
	scene.scale = OFFER_SCALE
	offer_container.add_child(scene)
	_center(scene)

func _clear_offer() -> void:
	for child in offer_container.get_children():
		child.queue_free()

func _center(scene: Node) -> void:
	await get_tree().process_frame
	if scene is Control:
		scene.position = (offer_container.size - scene.size * scene.scale) / 2.0
	else:
		scene.position = offer_container.size / 2.0

func _add_offer(scene: Node):
	if offer_container:
		offer_container.add_child(scene)
		if scene is Node2D:
			scene.position = offer_container.size / 2
		elif scene is Control:
			scene.position = (offer_container.size - scene.size) / 2

func _choose():
	is_picked = true
	Tooltip.unregister(frame)
	picked.emit(data)
	queue_free()
	
#func _animate_selection():
#	if position_tween:
#		position_tween.kill()
#	position_tween = create_tween()
#	var target_pos = default_pos + Vector2(0, -10) if selected else default_pos
#	var duration = 0.1 if selected else 0
#	position_tween.tween_property(frame, 'position', target_pos, duration)
	
func flip_open(delay := 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	Sound.play(Sound.SOUND_OFFER_FLIPPED)
	var t = create_tween()
	# close to edge-on (still showing the back)
	t.tween_property(frame, 'scale:x', 0.0, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# at the thin midpoint, swap to the front (unseen)
	t.tween_callback(func():
		frame.texture_normal = front_texture
		offer_container.visible = true
		title_container.visible = true
	)
	
	# open back to full, now showing the front
	t.tween_property(frame, 'scale:x', 1.0, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
func pop_open(custom_scale := Vector2.ONE):
	frame.scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(frame, "scale", custom_scale, 0.4)

func _shake_frame():
	if shake_tween:
		shake_tween.kill()          # don't stack on rapid re-hover       # rotate around the pack's center (Control only)
	shake_tween = create_tween()
	var angles = [4, -3, 2, -1, 0]
	for angle in angles:
		shake_tween.tween_property(frame, "rotation", deg_to_rad(angle), 0.07)
