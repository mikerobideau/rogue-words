extends BossData
class_name OvergrowthBoss

func get_turns_per_round(base: int) -> int:
	return base - 2

func get_leaves_per_round(base: int) -> int:
	return base + 2
