extends RelicData
class_name Octopus

func get_score(context: RelicContext) -> int:
	if context.word.length() >= 8:
		_add_x_scaling_value(x_scale_by)
		return round(context.word_score * x_scaling_value)
	return -1
	
func get_text(context: RelicContext) -> String:
	return 'Octopus x' + str(x_scaling_value)
