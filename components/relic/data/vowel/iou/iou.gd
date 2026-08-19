extends RelicData
class_name IOU

@export var money_reward: int
@export var countdown: int:
	set(v):
		countdown = v
		countdown_remaining = v

var countdown_remaining: int

var IOU_TOKENS = ['I', 'O', 'U']

func on_token_placed(context: RelicContext) -> RelicResponse:
	if context.placed_token.letter in IOU_TOKENS:
		countdown_remaining -= 1
		if countdown_remaining == 0:
			countdown_remaining = countdown
			GameState.money += money_reward
			return RelicResponse.MONEY_REWARD
		return RelicResponse.COUNTDOWN
	return RelicResponse.NONE

func get_on_placed_text(response: RelicResponse) -> String:
	if response == RelicResponse.MONEY_REWARD:
		return '+$' + str(money_reward)
	if response == RelicResponse.COUNTDOWN:
		return 'I\'ll pay you back!'
	return ''
	
func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (' + str(countdown_remaining) + ' remaining)'
