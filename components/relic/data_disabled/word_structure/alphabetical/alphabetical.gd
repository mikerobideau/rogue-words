extends RelicData
class_name Alphabetical

@export var mult: int

func get_score(context: RelicContext) -> int:
	if _is_alphabetical(context.word):
		return context.word_score * mult
	return -1
	
func get_score_text(context: RelicContext) -> String:
	if _is_alphabetical(context.word):
		return 'Alphabetical! x' + str(mult)
	return ''

func _is_alphabetical(word: String) -> bool:
	var upper := word.to_upper()
	for i in range(1, upper.length()):
		if upper[i] < upper[i - 1]:
			return false
	return true
