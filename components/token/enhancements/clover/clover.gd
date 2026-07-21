extends TokenEnhancement
class_name Clover

@export var one_out_of: int
@export var money_reward: int

func on_placed():
	if randf() <= 1 / one_out_of:
		GameState.money += money_reward
