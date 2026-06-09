extends RelicData
class_name Vine

func on_score_event(context: RelicContext):
	if 'V' in context.score_event.word:
		_add_bonus(scale_by)
		context.score_event.score += bonus
		return true
	return false
