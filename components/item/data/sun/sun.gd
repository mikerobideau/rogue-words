extends ItemData
class_name Sun

func enhance_token(token: Token) -> bool:
	token.value += 1
	return true
