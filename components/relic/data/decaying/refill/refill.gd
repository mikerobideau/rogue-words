extends RelicData
class_name RefillRelic

@export var base_mult: float:
	set(v):
		base_mult = v
		_reset()
@export var mult_decay: float
@export var decay_word_length: int
@export var reset_word_length: int

var current_mult: float
var min_mult = 1

func before_score(context: RelicContext) -> RelicResponse:
	if context.word.length() == decay_word_length:
		_decay()
		return RelicResponse.DECAY
	elif context.word.length() == reset_word_length:
		_reset()
		return RelicResponse.RESET_POSITIVE
	else:
		return RelicResponse.NONE

func get_score(context: RelicContext) -> int:
	return context.word_score * current_mult

func get_score_text(context: RelicContext) -> String:
	return 'Refill x' + str(current_mult)
	
func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (' + 'currently x' + str(current_mult) + ')'
	
func get_before_score_text(response: RelicResponse) -> String:
	match response: 
		RelicResponse.DECAY:
			return 'Gulp! -' + str(mult_decay)
		RelicResponse.RESET_POSITIVE:
			return 'Refill!'
		_:
			return ''

func _decay():
	current_mult = clamp(current_mult - mult_decay, min_mult, base_mult)

func _reset():
	current_mult = base_mult
