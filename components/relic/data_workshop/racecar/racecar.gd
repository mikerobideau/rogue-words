extends RelicData
class_name Racecar

func on_score_event(context: RelicContext):
	if _is_palindrome(context.score_event.word):
		context.score_event.score += 25
		return true
	return false

func _is_palindrome(word: String) -> bool:
	if word.length() <= 1:
		return true
	if word[0] != word[-1]:
		return false
	return _is_palindrome(word.substr(1, word.length() - 2))
