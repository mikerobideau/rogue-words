extends RelicData
class_name Cork

func get_mult(context: RelicContext) -> int:
	if context.turn_number <= 5:
		return 2
	return 0
