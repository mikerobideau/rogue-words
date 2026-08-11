extends RelicData
class_name PremiumGrapes

var num_rare_letters: int
var rare_letters = ['J', 'Q', 'V', 'X', 'Z']

func get_score(context: RelicContext) -> int:
	num_rare_letters = _get_num_rare_letters(context.word)
	if num_rare_letters > 0:
		return (num_rare_letters + 1) * context.word_score
	return -1

func get_score_text(context: RelicContext) -> String:
	if num_rare_letters > 0:
		return 'Premium! x' + str(num_rare_letters + 1)
	return ''

func _get_num_rare_letters(word: String) -> int:
	var count = 0
	for letter in word:
		if letter in rare_letters:
			count += 1
	return count
