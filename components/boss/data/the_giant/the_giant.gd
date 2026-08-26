extends BossData
class_name TheGiantBoss

func get_target_score(base: int) -> int:
	return roundi(base * 2.0)
