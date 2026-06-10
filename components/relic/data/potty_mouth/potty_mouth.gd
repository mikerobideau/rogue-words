extends RelicData
class_name PottyMouth

func on_score_event(context: RelicContext):
	if context.score_event.word.length() == 4:
		_add_bonus(scale_by)
		context.score_event.score += bonus
		return true
	return false
