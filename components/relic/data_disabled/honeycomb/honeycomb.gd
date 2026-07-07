extends RelicData
class_name Honeycomb

func get_score(context: RelicContext) -> int:
	if context.word.length() == 6:
		_add_scaling_value(scale_by)
		return context.word_score + scaling_value
	return -1
	
func get_text(context: RelicContext) -> String:
	return  'Honeycomb +' + str(scaling_value)
