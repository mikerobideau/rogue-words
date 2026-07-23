extends AnimatedSprite2D
class_name Space

const DISABLED_TEXTURE = preload("res://assets/sprites/space/1x/space_disabled.png")
const ENABLED_TEXTURE = preload("res://assets/sprites/space/1x/space.png")

@onready var label = $Label

signal clicked(space: Space)
signal hovered(space: Space)

@onready var badge = $Badge 

const RADIUS = 80
const DISABLED_RADIUS := RADIUS
const DOUBLE_WORD_COLOR = Styles.PINK
const TRIPLE_LETTER_COLOR = Styles.TEAL

var coord: Vector2i
var links: Array = [null, null, null, null, null, null]
var BASE_SCALE = Vector2(1.0, 1.0)

@export var data: SpaceData
@export var token: Token
@export var type: SpaceData.Type:
	get(): return data.type
	set(v): type = v; _update_label()
@export var disabled_color := Color(0.6, 0.6, 0.6, 0.5)

var enabled: bool = true:
	set(v):
		var was_enabled := enabled
		enabled = v
		queue_redraw()
		if is_node_ready():
			_animate()
		
		
		
func _ready():
	scale = BASE_SCALE
	play('default')
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	area.add_child(shape)
	add_child(area)
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(func(): if token == null: _animate())
	_update_label()
	_animate()
	
func _animate() -> void:
	label.visible = enabled
	play('default') if enabled else play('disabled')
		
func _on_mouse_entered():
	if !enabled:
		return
	Sound.play(Sound.SOUND_MOUSEOVER)
	if token == null:
		play('hover')
	hovered.emit(self)
	
func place_token(t: Token):
	#self_modulate.a = 0 #hide sprite
	play('default')
	token = t
	add_child(t)
	t.destroyed.connect(_on_token_destroyed)
	t.position = Vector2.ZERO
	t.on_placed()
	_show_badge()
	
func _on_token_destroyed():
	#self_modulate.a = 1 #show sprite
	token = null
	play('default')
	badge.visible = false
	
func modify_letter_score(v: int) -> int:
	return data.modify_letter_score(v)
	
func has_enhancement():
	return data.has_enhancement()
	
func pop_open():
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)

func _animate_badge():
	await get_tree().create_timer(0.4).timeout
	if token == null: #return if token has been destroyed
		return
	badge.scale = Vector2.ZERO
	badge.visible = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(badge, "scale", Vector2.ONE, 0.4)

func _show_badge():
	badge.z_index = 1
	badge.position = Vector2(-Token.RADIUS, 0)
	match data.type:
		SpaceData.Type.TRIPLE_LETTER:
			badge.color = TRIPLE_LETTER_COLOR
			badge.text = '3L'
			_animate_badge()
		SpaceData.Type.DOUBLE_WORD:
			badge.color = DOUBLE_WORD_COLOR
			badge.text = '2W'
			_animate_badge()
		_:
			badge.visible = false
	
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
		
func _update_label():
	match type:
		SpaceData.Type.TRIPLE_LETTER:
			label.text = '3L'
			_color_label(TRIPLE_LETTER_COLOR)
		SpaceData.Type.DOUBLE_WORD:
			label.text = '2W'
			_color_label(DOUBLE_WORD_COLOR)
		_:
			label.text = ''
	var sprite_size = sprite_frames.get_frame_texture("default", 0).get_size()
	label.position = -sprite_size / 2
	label.size = sprite_size
	badge.visible = false
			
func _color_label(color: String):
	label.add_theme_color_override("font_color", color)

func activate():
	await play('active')
