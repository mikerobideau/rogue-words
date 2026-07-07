extends RelicData
class_name Racecar

func get_score(context: RelicContext):
	if _is_palindrome(context.word):
		return context.word_score + 100
	return -1
	
func get_text(context: RelicContext):
	return 'Vroom! +100'

func _is_palindrome(word: String) -> bool:
	if word.length() <= 1:
		return true
	if word[0] != word[-1]:
		return false
	return _is_palindrome(word.substr(1, word.length() - 2))
