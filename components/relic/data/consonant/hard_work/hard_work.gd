extends RelicData
class_name HardWork

@export var juice_per_consonant: int

func get_juice(context: RelicContext) -> int:
	if context.scored_letter in TokenData.CONSONANTS:
		return juice_per_consonant
	return 0
