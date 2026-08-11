extends RelicData
class_name Cork

func get_score(context: RelicContext) -> int:
	if context.turn_number == 4:
		return context.word_score * 2
	return -1
	
func get_score_text(context: RelicContext) -> String:
	return 'POP! x2'
