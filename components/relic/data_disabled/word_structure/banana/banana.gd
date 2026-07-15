extends RelicData
class_name Banana

func get_score(context: RelicContext) -> int:
	if _has_at_least_three_of_a_letter(context.word):
		return context.word_score * 3
	return -1
	
func get_text(context: RelicContext) -> String:
	return 'Banana! x3'

func _has_at_least_three_of_a_letter(word: String) -> bool:
	var counts := {}
	for c in word.to_upper():
		counts[c] = counts.get(c, 0) + 1
		if counts[c] >= 3:
			return true
	return false
