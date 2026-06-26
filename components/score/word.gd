extends MarginContainer
class_name Word

const SOUND_TOKEN = 'token'
const SOUND_ENHANCED_TOKEN = 'shimmer_bonus'
const SOUND_ENHANCED_LETTER_SPACE = 'water_drop'
const SOUND_ENHANCED_WORD_SPACE = 'water_drop'
const SOUND_RELIC = 'bonus'

const DUPE_TOKEN_SCALE = Vector2(0.6, 0.6)

@onready var tokens = $TokenContainer/TokenMarginContainer/Tokens
@onready var plunger_container = $PlungerContainer
@onready var plunger = $Plunger

var word: String
var score: int
		
func _ready():
	pivot_offset = size / 2
	
func _plunge():
	await plunger.plunge_in()
	_squish()
	plunger.score = 0
	await plunger.plunge_out()

func _squish():
	for wrapper in tokens.get_children():
		wrapper.queue_free()

func set_score(v: int, delay: float):
	score = v
	if plunger:
		plunger.score = score
		plunger.shake_score(delay)

func play(word_report: WordReport, relic_report: RelicReport):
	word = word_report.word
	for letter_report in word_report.letter_reports:
		var token = await add_token(letter_report.space.token)
		for item in letter_report.items:
			var delay = Settings.SCORE_DELAY_LONG if item.is_enhanced_space or item.is_enhanced_token else Settings.SCORE_DELAY_NORMAL
			var sound = _get_letter_sound(item)
			Sound.play(sound)
			set_score(item.new_score, delay)
			token.pulse(delay)
			ScorePopup.show(item.text, token, delay, -30.0)
			await get_tree().create_timer(delay).timeout
	
	if word_report.word_mult_report:
		Sound.play(SOUND_ENHANCED_WORD_SPACE)
		var report = word_report.word_mult_report
		set_score(report.new_score, Settings.SCORE_DELAY_LONG)
		ScorePopup.show(report.text, plunger.label, Settings.SCORE_DELAY_LONG)
		await get_tree().create_timer(Settings.SCORE_DELAY_LONG).timeout
	
	for report in relic_report.items:
		Sound.play(SOUND_RELIC)
		report.relic.pulse(Settings.SCORE_DELAY_LONG)
		ScorePopup.show(report.text, report.relic, Settings.SCORE_DELAY_LONG)
		set_score(report.new_score, Settings.SCORE_DELAY_LONG)
		await get_tree().create_timer(0.3).timeout
	
	await _plunge()

func _get_letter_sound(item: LetterReportItem) -> String:
	if item.is_enhanced_space:
		return SOUND_ENHANCED_LETTER_SPACE
	if item.is_enhanced_token:
		return SOUND_ENHANCED_TOKEN
	return SOUND_TOKEN

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
	
