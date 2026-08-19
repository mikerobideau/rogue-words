extends RelicData
class_name PottyMouth

@export var juice: int

func get_juice(context: RelicContext) -> int:
	if context.word.length() == 4:
		return juice
	return 0
