extends RelicData
class_name CompostConsonants

@export var scale_by: int

var current_value := 0
var num_consonants := 0

func get_score(context: RelicContext) -> int:
	if current_value > 0:
		return context.word_score + current_value
	else:
		return -1

func get_discard_text(response: RelicResponse) -> String:
	return 'Compost! +' + str(num_consonants * scale_by)

func get_tooltip_text():
	return description + ' (currently +' + str(current_value) + ')'

func on_discard(context: RelicContext) -> RelicResponse:
	num_consonants = 0
	for token in context.discarded_tokens:
		if token.data.is_consonant():
			num_consonants += 1
	if num_consonants > 0:
		_scale(scale_by * num_consonants)
		return RelicResponse.UPGRADE
	return RelicResponse.NONE

func _scale(value: int):
	current_value += value
