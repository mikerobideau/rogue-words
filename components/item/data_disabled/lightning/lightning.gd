extends ItemData
class_name Lightning

const CHARGED_GRAPE = preload("res://components/token/enhancements/charged_grape/charged_grape.tres")

func enhance_token(token: Token) -> bool:
	token.enhance(CHARGED_GRAPE.duplicate())
	return true
