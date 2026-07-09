extends RelicData
class_name CompostConsonants

func get_score(context: RelicContext) -> int:
	if scaling_value > 0:
		return context.word_score + scaling_value
	else:
		return -1

func get_text(context: RelicContext) -> String:
	return 'Compost! +' + str(scaling_value)

func on_discard(context: RelicContext) -> bool:
	var num_consonants = 0
	for token in context.discarded_tokens:
		if token.data.is_consonant():
			num_consonants += 1
	if num_consonants > 0:
		_add_scaling_value(scale_by * num_consonants)
		return true
	return false
