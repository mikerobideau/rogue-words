extends ItemData
class_name Leprechaun

const CLOVER = preload("res://components/token/enhancements/clover/clover.tres")

func enhance_token(token: Token) -> bool:
	token.enhance(CLOVER.duplicate())
	return true
