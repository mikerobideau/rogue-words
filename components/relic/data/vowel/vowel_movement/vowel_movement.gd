extends RelicData
class_name VowelMovement

@export var scale_by: int

var current_value := 0
var num_vowels := 0

func get_score(context: RelicContext) -> int:
	if current_value > 0:
		return context.word_score + current_value
	else:
		return -1
		
func get_score_text(context: RelicContext) -> String:
	if current_value > 0:
		return 'Excuse me! +' + str(current_value)
	return ''

func get_discard_text(response: RelicResponse) -> String:
	return '+' + str(num_vowels * scale_by)

func get_tooltip_text(context: RelicContext):
	return description + ' (currently +' + str(current_value) + ')'

func on_discard(context: RelicContext) -> RelicResponse:
	num_vowels = 0
	for token in context.discarded_tokens:
		if token.data.is_vowel():
			num_vowels += 1
	if num_vowels > 0:
		_scale(scale_by * num_vowels)
		return RelicResponse.UPGRADE
	return RelicResponse.NONE

func _scale(value: int):
	current_value += value
