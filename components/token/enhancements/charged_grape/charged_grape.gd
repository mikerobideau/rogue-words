extends TokenEnhancement
class_name ChargedGrape

func on_scored(token: Token):
	token.value += 1
