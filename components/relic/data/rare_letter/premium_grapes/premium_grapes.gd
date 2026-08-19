extends RelicData
class_name PremiumGrapes

var num_rare_letters: int
var rare_letters = ['J', 'Q', 'V', 'X', 'Z']

func get_mult(context: RelicContext) -> int:
	if context.scored_letter in rare_letters:
		return 1
	return 0
