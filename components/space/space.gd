extends AnimatedSprite2D
class_name Space

signal clicked(space: Space)

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
	scale = Vector2.ZERO
	_update_sprite()
	_pop_open()
	
func place_token(t: Token):
	self_modulate.a = 0 #hide sprite
	token = t
	add_child(t)
	t.position = Vector2.ZERO
	t.on_token_placed()
	
func modify_letter_score(v: int) -> int:
	return data.modify_letter_score(v)
	
func _pop_open():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)
	
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
