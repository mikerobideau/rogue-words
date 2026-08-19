extends RelicData
class_name X4

func get_mult(context: RelicContext):
	if context.scored_letter == 'X':
		return 4
	return 0
