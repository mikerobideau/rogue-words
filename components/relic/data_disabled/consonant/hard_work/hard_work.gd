extends RelicData
class_name HardWork

@export var bonus: int

var num_consonants := 0

func get_score(context: RelicContext) -> int:
	num_consonants = _get_num_consonants(context.word)
	if num_consonants > 0:
		return context.word_score + (bonus * num_consonants)
	return -1
	
func get_score_text(context: RelicContext) -> String:
	return 'Hard work! +' + str(bonus * num_consonants)
	
func _get_num_consonants(word: String) -> int:
	var count := 0
	for letter in word:
		if letter in TokenData.CONSONANTS:
			count += 1
	return count
