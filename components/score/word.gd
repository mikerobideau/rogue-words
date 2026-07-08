extends Control
class_name Word

const DUPE_TOKEN_SCALE = Vector2(0.8, 0.8)

@onready var tokens = $Tokens
@onready var score_label = $Score

var word: String
var score: int:
	set(v):
		score = v
		score_label.text = str(v)
		
func _ready():
	score_label.pivot_offset = score_label.size / 2
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tokens.alignment = BoxContainer.ALIGNMENT_CENTER
	tokens.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func _squish():
	for wrapper in tokens.get_children():
		wrapper.queue_free()

func set_score(v: int, delay: float):
	score = v

func play(word_report: WordReport, relic_report: RelicReport):
	score_label.visible = true
	word = word_report.word
	for letter_report in word_report.letter_reports:
		var token = await add_token(letter_report.space.token)
		if letter_report.display_letter != letter_report.letter:
			token.letter_label.text = letter_report.display_letter
		for item in letter_report.items:
			var delay = Settings.SCORE_DELAY_LONG if item.is_enhanced_space or item.is_enhanced_token else Settings.SCORE_DELAY_NORMAL
			var sound = _get_letter_sound(item)
			Sound.play(sound)
			set_score(item.new_score, delay)
			token.pop_open(DUPE_TOKEN_SCALE)
			ScorePopup.show(item.text, token, delay, 0, -40)
			await get_tree().create_timer(delay).timeout
	
	if word_report.word_mult_report:
		Sound.play(Sound.SOUND_ENHANCED_WORD_SPACE)
		var report = word_report.word_mult_report
		set_score(report.new_score, Settings.SCORE_DELAY_LONG)
		ScorePopup.show(report.text, score_label, Settings.SCORE_DELAY_LONG, 
			10, 0, ScorePopup.Anchor.RIGHT)
		await get_tree().create_timer(Settings.SCORE_DELAY_LONG).timeout
	
	for report in relic_report.items:
		Sound.play(Sound.SOUND_RELIC)
		report.relic.pulse(Settings.SCORE_DELAY_LONG)
		ScorePopup.show(report.text, score_label, Settings.SCORE_DELAY_LONG, 10, 0, ScorePopup.Anchor.RIGHT)
		set_score(report.new_score, Settings.SCORE_DELAY_LONG)
		await get_tree().create_timer(0.3).timeout
		
	_squish()
	score_label.visible = false
	await get_tree().create_timer(0.3).timeout
	
func _get_letter_sound(item: LetterReportItem) -> String:
	if item.is_enhanced_space:
		return Sound.SOUND_ENHANCED_LETTER_SPACE
	if item.is_enhanced_token:
		return Sound.SOUND_ENHANCED_TOKEN
	return Sound.SOUND_TOKEN

func add_token(token: Token) -> Token:
	var dupe_token = token.duplicate()
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
	score = 0
	
func _get_token_size(token: Token) -> Vector2:
	var frames = token.sprite_frames
	return frames.get_frame_texture(token.animation, token.frame).get_size()

func _pulse_score():
	var delay = 0.1
	var tween = create_tween()
	tween.tween_property(score_label, 'scale', Vector2(1.1, 1.1), delay / 2)
	tween.tween_property(score_label, 'scale', Vector2(1.0, 1.0), delay / 2)
