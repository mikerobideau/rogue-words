extends RelicData
class_name Inventory

@export var bonus: int

var num_consonants := 0

func get_score(context: RelicContext) -> int:
	num_consonants = _get_num_consonants(context.tokens)
	if num_consonants > 0:
		return context.word_score + (bonus * num_consonants)
	return -1

func get_score_text(context: RelicContext) -> String:
	if num_consonants > 0:
		return 'Stocked! +' + str(bonus * num_consonants)
	return ''
	
func _get_num_consonants(tokens: Array[TokenData]) -> int:
	var count := 0
	for token in tokens:
		if token.is_consonant():
			count += 1
	return count

func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (currently +' + str(_get_num_consonants(context.tokens)) + ')'
