extends ItemData
class_name Lightning

func enhance_token(token: Token) -> bool:
	token.enhance(TokenData.Type.YELLOW_GRAPE)
	return true
