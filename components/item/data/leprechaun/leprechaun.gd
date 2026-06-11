extends ItemData
class_name Leprechaun

func enhance_token(token: Token) -> bool:
	token.enhance(Token.Type.CLOVER)
	return true
