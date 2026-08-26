extends BossData
class_name DroughtBoss

func get_token_value(base: int, letter: String) -> int:
	return 0 if letter.to_upper() in TokenData.VOWELS else base
