extends BossData
class_name MinusOneHandSizeBoss

func get_hand_size(base: int) -> int:
	return clamp(base - 1, 1, INF)
