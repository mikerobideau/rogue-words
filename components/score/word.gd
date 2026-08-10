extends Control
class_name Word

const DUPE_TOKEN_SCALE = Vector2(0.8, 0.8)

@onready var tokens = $Tokens

var word: String
		
func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tokens.alignment = BoxContainer.ALIGNMENT_CENTER
	tokens.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func play(word_score: WordScore, relic_report: RelicReport):
	word = word_score.word
	for tile in word_score.tiles:
		var token = await add_token(tile.space.token)
		if tile.display_letter != tile.space.token.letter:
			token.label.letter.text = tile.display_letter
		token.pop_open(DUPE_TOKEN_SCALE)
		if token.enhancement:
			token.data.enhancement.on_scored()

func _get_letter_sound(item: LetterReportItem) -> String:
	if item.is_enhanced_space:
		return Sound.SOUND_ENHANCED_LETTER_SPACE
	if item.is_enhanced_token:
		return Sound.SOUND_ENHANCED_TOKEN
	return Sound.SOUND_TOKEN

func add_token(token: Token) -> Token:
	var dupe_token = token.duplicate()
	dupe_token.is_animated = false
	dupe_token.scale = DUPE_TOKEN_SCALE
	var wrapper = Control.new()
	var token_size = _get_token_size(dupe_token) * dupe_token.scale
	wrapper.custom_minimum_size = token_size
	wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tokens.add_child(wrapper)
	wrapper.add_child(dupe_token) 
	await get_tree().process_frame
	dupe_token.position += wrapper.size / 2
	return dupe_token

func clear():
	for letter in tokens.get_children():
		letter.queue_free()
	
func fly_tokens_to(target_global: Vector2) -> void:
	var dupes := _dupe_tokens()
	var last: Tween
	for i in dupes.size():
		var dupe: Token = dupes[i]
		var start := dupe.global_position
		dupe.top_level = true
		dupe.global_position = start
		dupe.is_animated = true
		var t := create_tween()
		t.tween_interval(i * 0.06)
		t.tween_property(dupe, "global_position", target_global, 0.35) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_callback(dupe.queue_free)
		dupe.animate_destroyed(0.2)
		last = t
	if last:
		await last.finished

func _dupe_tokens() -> Array:
	var result := []
	for wrapper in tokens.get_children():
		for child in wrapper.get_children():
			if child is Token:
				result.append(child)
	return result
	
func _get_token_size(token: Token) -> Vector2:
	var frames = token.sprite_frames
	return frames.get_frame_texture(token.animation, token.frame).get_size()
