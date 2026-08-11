extends RelicData
class_name Lucky

@export var money_reward: int

func on_token_placed(context: RelicContext) -> RelicResponse:
	if 'LUCKY'.contains(context.placed_token.data.letter):
		#if randf() < 0.25:
		if randf() < 1:
			GameState.money += money_reward
			return RelicResponse.MONEY_REWARD
	return RelicResponse.NONE

func get_on_placed_text(response: RelicResponse) -> String:
	if response == RelicResponse.MONEY_REWARD:
		return 'That\'s lucky!'
	return ''
