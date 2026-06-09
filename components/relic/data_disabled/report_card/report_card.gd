extends RelicData
class_name ReportCard

func on_token_placed(context: RelicContext) -> bool:
	if context.placed_token.letter in ['B', 'C', 'D', 'F']:
		_reset_count()
		return false
	if context.placed_token.letter == 'A':
		_add_count(1)
		if count >= 5:
			context.state.money += money_reward
			_reset_count()
			return true
	return false
