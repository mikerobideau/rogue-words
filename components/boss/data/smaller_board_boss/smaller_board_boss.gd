extends BossData
class_name SmallerBoardBoss

func get_starting_board_size(base: int) -> int:
	return clamp(base - 1, 1, INF)
