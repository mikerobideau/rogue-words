extends RelicData
class_name HardWork

@export var juice_per_consonant: int

func get_juice(context: RelicContext) -> int:
	if context.scored_letter in TokenData.CONSONANTS:
		return juice_per_consonant
	return 0

func upgrade() -> void:
	juice_per_consonant += 1
	super()

func get_upgrade_text() -> String:
	return '+1 juice per consonant'
