extends BossData
class_name WindBoss

func on_turn_scored(board) -> void:
	if board.has_method("swap_random_tokens"):
		board.swap_random_tokens()
