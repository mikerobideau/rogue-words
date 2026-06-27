extends AnimatedSprite2D
class_name Space

var double_letter_badge = preload("res://assets/sprites/space/1x/badge_2l.png")
var double_word_badge = preload("res://assets/sprites/space/1x/badge_2w.png")

signal clicked(space: Space)

@onready var badge = $Badge 

const RADIUS = 40

var coord: Vector2i
var links: Array = [null, null, null, null, null, null]

@export var data: SpaceData
@export var token: Token
@export var standard_frames: SpriteFrames
@export var double_letter_frames: SpriteFrames
@export var double_word_frames: SpriteFrames

@export var type: SpaceData.Type:
	get(): return data.type
	set(v): type = v; _update_sprite()

func _ready():
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	area.add_child(shape)
	add_child(area)
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(func(): if token == null:play('default'))
	scale = Vector2.ZERO
	_update_sprite()
	_pop_open()
	
func _on_mouse_entered():
	if token == null:
		play('hover')
	
func place_token(t: Token):
	self_modulate.a = 0 #hide sprite
	token = t
	add_child(t)
	t.position = Vector2.ZERO
	t.on_placed()
	_show_badge()
	
func modify_letter_score(v: int) -> int:
	return data.modify_letter_score(v)
	
func has_enhancement():
	return data.has_enhancement()
	
func _pop_open():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)

func _animate_badge():
	await get_tree().create_timer(0.4).timeout
	badge.scale = Vector2.ZERO
	badge.visible = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(badge, "scale", Vector2.ONE, 0.4)

func _show_badge():
	badge.z_index = 1
	badge.position = Vector2(0, Token.RADIUS)
	match data.type:
		SpaceData.Type.DOUBLE_LETTER:
			badge.texture = double_letter_badge
			_animate_badge()
		SpaceData.Type.DOUBLE_WORD:
			badge.texture = double_word_badge
			_animate_badge()
		_:
			badge.visible = false
	
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
		
func _update_sprite():
	if not is_node_ready():
		return
	match type:
		SpaceData.Type.STANDARD:
			sprite_frames = standard_frames
		SpaceData.Type.DOUBLE_LETTER:
			sprite_frames = double_letter_frames
		SpaceData.Type.DOUBLE_WORD:
			sprite_frames = double_word_frames
	animation = 'default'
