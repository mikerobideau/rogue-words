extends ItemData
class_name Water

func enhance_token(token: Token) -> bool:
	token.next_letter()
	return true
