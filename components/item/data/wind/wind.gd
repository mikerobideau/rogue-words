extends ItemData
class_name Wind

func enhance_token(token: Token):
	token.swap_random_consonant_vowel()
	return true
