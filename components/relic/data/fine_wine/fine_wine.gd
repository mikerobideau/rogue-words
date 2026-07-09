extends RelicData
class_name FineWine

func on_round_complete(context: RelicContext):
	GameState.money += money_reward
	money_reward += 1
	return true
