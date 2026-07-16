extends RelicData
class_name Honeycomb

@export var bonus: int

func get_score(context: RelicContext) -> int:
	if context.word.length() == 6:
		return context.word_score + bonus
	return -1
	
func get_text(context: RelicContext) -> String:
	return  'Honeycomb! +' + str(bonus)
