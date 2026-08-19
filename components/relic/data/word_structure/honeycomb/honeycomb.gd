extends RelicData
class_name Honeycomb

@export var juice: int

func get_juice(context: RelicContext) -> int:
	if context.word.length() == 6:
		return juice
	return 0
