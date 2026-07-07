extends RelicData
class_name HealthInspection

func on_token_placed(context: RelicContext) -> bool:
	if context.placed_token.letter == 'A':
		_add_scaling_value(scale_by)
		return true
	if context.placed_token.letter in ['B', 'C', 'D', 'F']:
		scaling_value = 0
	return false
		
func get_score(context: RelicContext) -> int:
	if scaling_value > 0:
		return context.word_score + scaling_value
	return -1
	
func get_text(context: RelicContext) -> String:
	return 'Straight A\'s +' + str(scaling_value)
