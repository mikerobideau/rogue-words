extends RelicData
class_name Juice

@export var value: int

func get_score(context: RelicContext) -> int:
	return context.word_score + value
	
func get_score_text(context: RelicContext):
	return 'Juice +' + str(value)
