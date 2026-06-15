extends ItemData
class_name Leprechaun

func enhance_token(token: Token) -> bool:
	token.enhance(TokenData.Type.CLOVER)
	return true
