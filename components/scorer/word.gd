extends MarginContainer
class_name Word

@onready var tokens = $TokenContainer/Tokens
@onready var score_label = $Score

@export var score := 0:
	set(v):
		score = v
		_update_score()
		
func _ready():
	_update_score(false)
	pivot_offset = size / 2

func play(word: String):
	for letter in word:
		var token = TokenFactory.create_scene_by_letter_and_type(letter, TokenData.Type.GRAPE)
		add_token(token)
		add_score(1)
		await get_tree().create_timer(0.1).timeout

func add_token(token: Token):
	var dupe_token = token.duplicate()
	dupe_token.scale = Vector2(0.6, 0.6)
	var wrapper = Control.new()
	var token_size = _get_token_size(dupe_token) * dupe_token.scale
	wrapper.custom_minimum_size = token_size
	tokens.add_child(wrapper)
	wrapper.add_child(dupe_token) 
	#dupe_token.centered = false #properly centers token alignment inside center container > hbox container
	dupe_token.position += token_size / 2
	await get_tree().process_frame
	dupe_token.pulse(0.3)
	
func _get_token_size(token: Token) -> Vector2:
	var frames = token.sprite_frames
	return frames.get_frame_texture(token.animation, token.frame).get_size()
	
func clear():
	for letter in tokens.get_children():
		letter.queue_free()
	score = 0

func add_score(value: int):
	score += value
	
func _update_score(shake := true):
	if score_label:
		score_label.text = str(score) if score > 0 else ''
		if shake:
			_shake()

func _shake():
	var tween = create_tween()
	var start_rotation = 0
	tween.tween_property(score_label, 'scale', Vector2(1.2, 1.2), 0.03)
	tween.tween_property(score_label, 'rotation', start_rotation + deg_to_rad(3), 0.05)
	tween.tween_property(score_label, 'rotation', start_rotation - deg_to_rad(3), 0.05)
	tween.tween_property(score_label, 'rotation', start_rotation, 0.03)
	tween.tween_property(score_label, 'scale', Vector2(1.0, 1.0), 0.06)
