extends AnimatedSprite2D
class_name Token

signal clicked()

const RADIUS = 40

enum Type {
	GRAPE,
	CLOVER
}

@onready var letter_label = $Letter
@export var letter: String
@export var value: int
@export var type: Type

var selected: bool = false:
	set(value):
		selected = value
		_on_selected_changed()

func _ready():
	type = Type.GRAPE
	animation = 'default'
	_update_label()
	_init_click_detection()
	
func enhance(t: Type):
	type = t
	
func animate_highlight():
	animation = 'highlight'

func animate_default():	
	animation = 'default'

func _update_label():
	letter_label.text = letter
	
func _init_click_detection():
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	area.add_child(shape)
	add_child(area)
	area.input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
		
func _on_selected_changed():
	queue_redraw()
	var tween = create_tween()
	var target = Vector2(1.2, 1.2) if selected else Vector2(1, 1)
	tween.tween_property(self, "scale", target, 0.15)
