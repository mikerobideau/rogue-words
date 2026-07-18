extends AnimatedSprite2D
class_name Token

signal clicked()
signal destroyed()

const RADIUS = 48

@onready var label = $TokenLabel

@export var data: TokenData:
	set(v):
		data = v
		_update_label()
		_update_sprite()
		
@export var enhancement: TokenEnhancement:
	get(): return data.enhancement
	set(v): 
		enhancement = v
		_update_sprite()

@export var letter: String:
	get(): return data.letter
	set(v): 
		data.letter = v; 
		_update_label()
		
@export var value: int:
	get(): return data.value
	set(v): 
		data.value = v
		_update_label()
		
var is_selectable := true
		
var selected: bool = false:
	set(v): 
		if is_selectable:
			selected = v
			_on_selected()
	
var scale_tween: Tween
var transform_tween: Tween

func _ready():
	animation = 'default'
	_update_label()
	_update_sprite()
	_init_click_detection()
	data.letter_changed.connect(_on_letter_changed)
	data.value_changed.connect(_on_value_changed)
	
func enhance(e: TokenEnhancement):
	Tooltip.hide_for_node()
	data.enhance(e)
	_transform()
	
func destroy():
	Sound.play(Sound.SOUND_TOKEN_DESTROYED)
	destroyed.emit()
	_animate_destroyed()
	
func next_letter():
	data.next_letter()
	
func swap_random_consonant_vowel():
	data.swap_random_consonant_vowel()
	
func get_mult() -> int:
	if enhancement:
		return enhancement.get_mult()
	return 1
	
func get_plus_score() -> int:
	if enhancement:
		return enhancement.get_plus_score()
	return 0
	
func _on_selected():
	if selected:
		_animate_selected()
	else:
		_animate_deselected()
	
func on_placed():
	data.spent = true
	_animate_deselected()
	is_selectable = false
	if data.enhancement:
		data.enhancement.on_placed()
		
func _on_letter_changed():
	_transform()
	_update_label(true)
	
func _on_value_changed():
	_transform()
	_update_label(true)

func _update_sprite():
	if data.enhancement:
		sprite_frames = data.enhancement.sprite_frames
	play('default')
	
func _update_label(transition := false):
	if transition and is_inside_tree():
		var tween = create_tween()
		tween.tween_property(label, 'modulate:a', 0, 0.2)
		await get_tree().create_timer(0.3).timeout
	if label:
		label.letter.text = letter
		label.value.text = NumberUtil.short_format(value)
	if transition and is_inside_tree():
		var tween = create_tween()
		tween.tween_property(label, 'modulate:a', 1, 0.2)
	
func _show_tooltip():
	Tooltip.show_for_node(self, get_tooltip_text())
	
func get_tooltip_text():
	var type = 'Grape' if enhancement == null else 'Enhanced'
	return type + ' ' + data.letter + ' (' + str(data.value) + ' mL)'
	
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
	_show_tooltip()
	if is_selectable and not selected: 
		Sound.play(Sound.SOUND_MOUSEOVER)
		scale_up()

func _on_mouse_exited():
	Tooltip.hide_for_node()
	if is_selectable and not selected: 
		scale_down()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

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
	
func pop_open(custom_scale := Vector2.ONE):
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", custom_scale, 0.4)
	
func _animate_destroyed(custom_scale := Vector2.ONE):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.8)
	await tween.finished
	queue_free()
	
func _transform():
	var was_selectable := is_selectable
	is_selectable = false #disable selection during transformation to prevent transform and mouseover animations from competing
	if scale_tween:
		scale_tween.kill()
	
	transform_tween = create_tween()
	# impact reaction — quick squash, like it got hit
	transform_tween.tween_property(self, 'scale', Vector2(1.2, 0.8), 0.08) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	# flip closed on X axis
	transform_tween.tween_property(self, 'scale:x', 0.0, 0.12) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# swap sprite_frames at the moment it's edge-on, invisible
	transform_tween.tween_callback(_update_sprite)
	
	# flip open with overshoot, settling like _animate_placed
	transform_tween.tween_property(self, 'scale', Vector2(1.3, 1.3), 0.15) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	transform_tween.tween_property(self, 'scale', Vector2(0.9, 0.9), 0.08)
	transform_tween.tween_property(self, 'scale', Vector2(1.0, 1.0), 0.08)
	transform_tween.tween_callback(func(): is_selectable = was_selectable)
