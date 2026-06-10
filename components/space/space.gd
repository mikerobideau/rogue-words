extends Sprite2D
class_name Space

signal clicked(space: Space)

@export var token: Token

const RADIUS = 40

var coord: Vector2i
var links: Array = [null, null, null, null, null, null]

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
	_pop_open()
	
func place_token(t: Token):
	texture = null
	token = t
	add_child(t)
	t.position = Vector2.ZERO
	t.on_token_placed()
	
func _pop_open():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)
	
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
