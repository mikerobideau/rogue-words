extends ItemData
class_name Lightning

func enhance_token(token: Token) -> bool:
	token.enhance(Token.Type.YELLOW_GRAPE)
	return true
