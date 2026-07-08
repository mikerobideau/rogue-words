extends ItemData
class_name Pepper

const SPICY_GRAPE = preload("res://components/token/enhancements/spicy_grape/spicy_grape.tres")

func enhance_token(token: Token) -> bool:
	token.enhance(SPICY_GRAPE.duplicate())
	return true
