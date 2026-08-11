extends RelicData
class_name TopShelf

@export var money_reward: int

var rare_letters = ['J', 'Q', 'V', 'X', 'Z']

func on_token_placed(context: RelicContext) -> RelicResponse:
	print_debug('checking on placed')
	print_debug('letter is ' + str(context.placed_token.letter))
	if context.placed_token.letter in rare_letters:
		GameState.money += money_reward
		return RelicResponse.MONEY_REWARD
	return RelicResponse.NONE

func get_on_placed_text(response: RelicResponse) -> String:
	if response == RelicResponse.MONEY_REWARD:
		return 'Elegant! +$1'
	return ''
