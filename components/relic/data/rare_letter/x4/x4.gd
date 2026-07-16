extends RelicData
class_name XFactor

func get_score(context: RelicContext):
	if 'X' in context.word:
		return context.word_score * 4
	return -1
	
func get_score_text(context: RelicContext) -> String:
	return 'X4 x4'
