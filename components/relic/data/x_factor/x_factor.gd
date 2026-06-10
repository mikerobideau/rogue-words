extends RelicData
class_name XFactor

func on_score_event(context: RelicContext):
	if 'X' in context.score_event.word:
		var score = context.score_event.score
		var new_score = score * 2
		context.score_event.score = new_score
		return true
	return false
