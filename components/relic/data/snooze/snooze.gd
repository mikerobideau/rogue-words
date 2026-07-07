extends RelicData
class_name Snooze

func get_score(context: RelicContext) -> int:
	if context.placed_token.letter == 'Z':
		_add_scaling_value(scale_by)
		return context.word_score + scaling_value
	return -1
	
func get_text(context: RelicContext) -> String:
	return  'Zzz +' + str(scaling_value)
