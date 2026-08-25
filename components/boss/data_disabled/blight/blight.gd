extends BossData
class_name BlightBoss

func get_token_value(base: int, letter: String) -> int:
	return roundi(base / 2.0)
