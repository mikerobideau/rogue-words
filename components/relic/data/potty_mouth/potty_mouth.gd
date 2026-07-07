extends RelicData
class_name PottyMouth

func get_score(context: RelicContext) -> int:
	if context.word.length() == 4:
		_add_bonus(scale_by)
		return context.word_score + bonus
	return context.word_score
	
func get_text(context: RelicContext) -> String:
	return  'Potty Mouth +' + str(bonus)
