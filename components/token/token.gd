extends AnimatedSprite2D
class_name Token

signal clicked()

const RADIUS = 48

@onready var letter_label = $Letter
@onready var value_label = $Value

@export var grape_frames: SpriteFrames
@export var green_grape_frames: SpriteFrames
@export var yellow_grape_frames: SpriteFrames
@export var clover_frames: SpriteFrames

@export var data: TokenData
		
@export var type: TokenData.Type:
	get(): return data.type
	set(v): type = v; _update_sprite()

@export var letter: String:
	get(): return data.letter
	set(v): data.letter = v; _update_label()
		
@export var value: int:
	get(): return data.value
	set(v): value = v; _update_label()
		
var is_selectable := true
		
var selected: bool = false:
	set(v): 
		if is_selectable:
			selected = v
			_on_selected()
	
var scale_tween: Tween

func _ready():
	animation = 'default'
	_setup_label()
	_update_label()
	_update_sprite()
	_init_click_detection()
	
func enhance(t: TokenData.Type):
	data.enhance(t)
	_update_sprite()
	
func next_letter():
	data.next_letter()
	
func swap_random_consonant_vowel():
	data.swap_random_consonant_vowel()
	
func _on_selected():
	if selected:
		_animate_selected()
	else:
		_animate_deselected()
	
func on_placed():
	selected = false
	is_selectable = false
	_animate_placed()
	if type == TokenData.Type.CLOVER:
		if randf() <= 0.25:
			GameState.money += 5
	if type == TokenData.Type.GREEN_GRAPE:
		GameState.money += 1

func _setup_label():
	var label = letter_label
	label.position = Vector2(-label.size.x / 2, -label.size.y / 2)
	
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
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if is_selectable and not selected: 
		Sound.play('token')
		scale_up()

func _on_mouse_exited():
	if is_selectable and not selected: 
		scale_down()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
	
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

#
#Animation
#

func scale_up():
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(self, 'scale', Vector2(1.2, 1.2), 0.2)
	
func scale_down():
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(self, 'scale', Vector2(1, 1), 0.2)
	
func _animate_placed():
	if scale_tween:
		scale_tween.kill()
	var scale_tween = create_tween()
	scale = Vector2(0, 0)
	scale_tween.tween_property(self, 'scale', Vector2(1.2, 1.2), 0.2)
	scale_tween.tween_property(self, 'scale', Vector2(0.8, 0.8), 0.1)
	scale_tween.tween_property(self, 'scale', Vector2(1.1, 1.1), 0.1)
	scale_tween.tween_property(self, 'scale', Vector2(0.9, 0.9), 0.1)
	scale_tween.tween_property(self, 'scale', Vector2(1.0, 1.0), 0.1)
	
func _animate_selected():
	if scale_tween:
		scale_tween.kill()
	var scale_tween = create_tween()
	scale_tween.tween_property(self, 'scale', Vector2(1.4, 1.4), 0.1)
	scale_tween.tween_property(self, 'scale', Vector2(1.0, 1.0), 0.1)
	scale_tween.tween_property(self, 'scale', Vector2(1.3, 1.3), 0.1)
	scale_tween.tween_property(self, 'scale', Vector2(1.1, 1.1), 0.1)
	scale_tween.tween_property(self, 'scale', Vector2(1.2, 1.2), 0.1)
	
func _animate_deselected():
	scale_down()

func pulse(letter_delay: float):
	if scale_tween:
		scale_tween.kill()
	var scale_tween = create_tween()
	var base_scale = scale
	scale_tween.tween_property(self, 'scale', base_scale * 1.2, letter_delay / 5)
	scale_tween.tween_property(self, 'scale', base_scale * 0.8, letter_delay / 5)
	scale_tween.tween_property(self, 'scale', base_scale * 1.1, letter_delay / 5)
	scale_tween.tween_property(self, 'scale', base_scale * 0.9, letter_delay / 5)
	scale_tween.tween_property(self, 'scale', base_scale, letter_delay / 5)
	
