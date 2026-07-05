extends TokenEnhancement
class_name Clover

func on_placed():
	if randf() <= 1:
		GameState.money += 5
