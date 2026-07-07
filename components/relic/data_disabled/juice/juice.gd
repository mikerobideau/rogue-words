extends RelicData
class_name Juice

func get_score(context: RelicContext):
	return context.word_score + 10
	
func get_text(context: RelicContext):
	return 'Juice +10'
