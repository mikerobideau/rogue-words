extends RelicData
class_name FineWine

var money_reward := 1
var last_money_reward := 1

func on_round_complete(context: RelicContext):
	GameState.money += money_reward
	last_money_reward = money_reward
	money_reward += 1
	return RelicResponse.MONEY_REWARD

func get_round_complete_text(response: RelicResponse):
	return '+' + str(last_money_reward)
