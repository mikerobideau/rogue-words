extends RelicData
class_name Noon

@export var juice: int

func get_juice(context: RelicContext):
	if _is_palindrome(context.word):
		return juice
	return 0
	
func _is_palindrome(word: String) -> bool:
	if word.length() <= 1:
		return true
	if word[0] != word[-1]:
		return false
	return _is_palindrome(word.substr(1, word.length() - 2))
