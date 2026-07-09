extends RelicData
class_name Lucky

func on_token_placed(context: RelicContext) -> bool:
	if 'LUCKY'.contains(context.placed_token.data.letter):
		if randf() < 0.25:
			GameState.money += money_reward
			return true
	return false
