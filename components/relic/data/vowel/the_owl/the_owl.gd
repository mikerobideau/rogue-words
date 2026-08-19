extends RelicData
class_name TheOwl

@export var bonus: int

var num_vowels := 0

func get_juice(context: RelicContext) -> int:
	if context.scored_letter in TokenData.VOWELS:
		return bonus
	return 0
