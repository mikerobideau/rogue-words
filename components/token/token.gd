extends AnimatedSprite2D
class_name Token

signal clicked()

const RADIUS = 40
const VOWELS = ['A', 'E', 'I', 'O', 'U']
const CONSONANTS = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']

@onready var letter_label = $Letter
@onready var value_label = $Value

@export var data: TokenData:
	set(v):
		data = v
		type = data.type
		letter = data.letter
		value = data.value
@export var type: TokenData.Type:
	set(v):
		type = v
		_update_sprite()
@export var letter: String:
	set(v):
		letter = v
		_update_label()
@export var value: int:
	set(v):
		value = v
		_update_label()
@export var grape_frames: SpriteFrames
@export var green_grape_frames: SpriteFrames
@export var yellow_grape_frames: SpriteFrames
@export var clover_frames: SpriteFrames

var selected: bool = false:
	set(v):
		selected = v
		_on_selected_changed()

func _ready():
	if data:
		type = data.type
		letter = data.letter
		value = data.value
	animation = 'default'
	_update_label()
	_update_sprite()
	_init_click_detection()
	
func enhance(t: TokenData.Type):
	type = t
	
func next_letter():
	print_debug('next letter')
	var code = letter.to_upper().unicode_at(0)
	letter = char((code - 65 + 1) % 26 + 65)
	
func swap_random_consonant_vowel():
	if letter in VOWELS:
		letter = CONSONANTS[randi() % CONSONANTS.size()]
	else:
		letter = VOWELS[randi() % VOWELS.size()]
	
func pulse(letter_delay: float):
	var tween = create_tween()
	tween.tween_property(self, 'scale', Vector2(1.2, 1.2), letter_delay / 5)
	tween.tween_property(self, 'scale', Vector2(0.8, 0.8), letter_delay / 5)
	tween.tween_property(self, 'scale', Vector2(1.1, 1.1), letter_delay / 5)
	tween.tween_property(self, 'scale', Vector2(0.9, 0.9), letter_delay / 5)
	tween.tween_property(self, 'scale', Vector2(1, 1), letter_delay / 5)
	
func scale_up():
	var tween = create_tween()
	tween.tween_property(self, 'scale', Vector2(1.1, 1.1), 0.3)
	
func scale_down():
	var tween = create_tween()
	tween.tween_property(self, 'scale', Vector2(1, 1), 0.3)
	
func on_token_placed():
	if type == TokenData.Type.CLOVER:
		if randf() <= 0.25:
			GameState.money += 5
	if type == TokenData.Type.GREEN_GRAPE:
		GameState.money += 1

func _update_label():
	if letter_label:
		letter_label.text = letter
	if value_label:
		value_label.text = str(value)
	
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
		TokenData.Type.GRAPE:
			sprite_frames = grape_frames
		TokenData.Type.GREEN_GRAPE:
			sprite_frames = green_grape_frames
		TokenData.Type.YELLOW_GRAPE:
			sprite_frames = yellow_grape_frames
		TokenData.Type.CLOVER:
			sprite_frames = clover_frames
			
	animation = 'default'
