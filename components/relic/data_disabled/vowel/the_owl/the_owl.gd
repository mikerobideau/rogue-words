extends RelicData
class_name TheOwl

@export var bonus: int

var num_vowels := 0

func get_score(context: RelicContext) -> int:
	num_vowels = _get_num_vowels(context.word)
	if num_vowels > 0:
		return context.word_score + (bonus * num_vowels)
	return -1
	
func get_score_text(context: RelicContext) -> String:
	return 'Hoo hoo! +' + str(bonus * num_vowels)
	
func _get_num_vowels(word: String) -> int:
	var count := 0
	for letter in word:
		if letter in TokenData.VOWELS:
			count += 1
	return count
