extends RelicData
class_name Collector

@export var bonus: int

var rare_letters = ['J', 'Q', 'V', 'X', 'Z']
var num_rare_letters := 0

func get_score(context: RelicContext) -> int:
	num_rare_letters = _get_num_rare_letters(context.tokens)
	if num_rare_letters > 0:
		return context.word_score + (bonus * num_rare_letters)
	return -1

func get_score_text(context: RelicContext) -> String:
	if num_rare_letters > 0:
		return 'Nice collection! +' + str(bonus * num_rare_letters)
	return ''
	
func _get_num_rare_letters(tokens: Array[TokenData]) -> int:
	var count := 0
	for token in tokens:
		if token.letter in rare_letters:
			count += 1
	return count

func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (currently ' + str(_get_num_rare_letters(context.tokens)) + ')'
