extends AnimatedSprite2D
class_name Token

signal clicked()

const RADIUS = 40

enum Type {
	GRAPE,
	CLOVER
}

@onready var letter_label = $Letter

@export var grape_frames: SpriteFrames
@export var clover_frames: SpriteFrames
@export var letter: String
@export var value: int

@export var type: = Type.GRAPE:
	set(v):
		type = v
		_update_sprite()

var selected: bool = false:
	set(v):
		selected = v
		_on_selected_changed()

func _ready():
	type = Type.GRAPE
	animation = 'default'
	_update_label()
	_init_click_detection()
	
func enhance(t: Type):
	type = t
	
func pulse():
	var tween = create_tween()
	tween.tween_property(self, 'scale', Vector2(1.2, 1.2), 0.05)
	tween.tween_property(self, 'scale', Vector2(0.8, 0.8), 0.05)
	tween.tween_property(self, 'scale', Vector2(1.1, 1.1), 0.05)
	tween.tween_property(self, 'scale', Vector2(0.9, 0.9), 0.05)
	tween.tween_property(self, 'scale', Vector2(1, 1), 0.15)
	
#func animate_highlight():
#	animation = 'highlight'

#func animate_default():	
#	animation = 'default'
	
func on_token_placed():
	if type == Type.CLOVER:
		if randf() <= 0.25:
			GameState.money += 5

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
	
func _update_sprite():
	if not is_node_ready():
		return
		
	match type:
		Type.GRAPE:
			sprite_frames = grape_frames
		Type.CLOVER:
			sprite_frames = clover_frames
			
	animation = 'default'
