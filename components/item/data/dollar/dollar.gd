extends ItemData
class_name Dollar

func enhance_token(token: Token) -> bool:
	token.enhance(Token.Type.GREEN_GRAPE)
	return true
