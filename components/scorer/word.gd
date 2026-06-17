extends MarginContainer
class_name Word

@onready var tokens = $Tokens

func _ready():
	pass
	#pivot_offset = size / 2

func play(word: String):
	for letter in word:
		var token = TokenFactory.create_scene_by_letter_and_type(letter, TokenData.Type.GRAPE)
		add_token(token)
		await get_tree().create_timer(0.1).timeout

func add_token(token: Token):
	var dupe_token = token.duplicate()
	var wrapper = Control.new()
	var token_size = _get_token_size(dupe_token)
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
