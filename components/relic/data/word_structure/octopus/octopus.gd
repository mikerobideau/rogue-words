extends RelicData
class_name Octopus

@export var mult: int

func get_mult(context: RelicContext) -> int:
	if context.word.length() >= 8:
		return mult
	return 0
