extends RelicData
class_name Vine

func get_score(context: RelicContext):
	if 'V' in context.word:
		_add_scaling_value(scale_by)
		return context.word_score + scaling_value
	return -1
	
func get_text(context: RelicContext):
	return 'Vine +' + str(scaling_value)
