extends RelicData
class_name XFactor

func get_score(context: RelicContext):
	if 'X' in context.word:
		return context.word_score * 2
	return -1
	
func get_text(context: RelicContext):
	return 'X Factor x2'
