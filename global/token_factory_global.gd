extends Node
class_name TokenFactoryGlobal

var TokenScene = preload("res://components/token/token.tscn")

const LETTERS: Dictionary = {
	"A": {'letter': 'A', 'value': 1, 'freq': 5}, 
	"B": {'letter': 'B', 'value': 3, 'freq': 1}, 
	"C": {'letter': 'C', 'value': 3, 'freq': 3}, 
	"D": {'letter': 'D', 'value': 2, 'freq': 1}, 
	"E": {'letter': 'E', 'value': 1, 'freq': 5}, 
	"F": {'letter': 'F', 'value': 4, 'freq': 1}, 
	"G": {'letter': 'G', 'value': 2, 'freq': 1}, 
	"H": {'letter': 'H', 'value': 4, 'freq': 1}, 
	"I": {'letter': 'I', 'value': 1, 'freq': 5}, 
	"J": {'letter': 'J', 'value': 8, 'freq': 1}, 
	"K": {'letter': 'K', 'value': 5, 'freq': 1}, 
	"L": {'letter': 'L', 'value': 1, 'freq': 3}, 
	"M": {'letter': 'M', 'value': 3, 'freq': 1}, 
	"N": {'letter': 'N', 'value': 1, 'freq': 3}, 
	"O": {'letter': 'O', 'value': 1, 'freq': 5}, 
	"P": {'letter': 'P', 'value': 3, 'freq': 1}, 
	"Q": {'letter': 'Q', 'value': 10, 'freq': 1}, 
	"R": {'letter': 'R', 'value': 1, 'freq': 3}, 
	"S": {'letter': 'S', 'value': 1, 'freq': 3}, 
	"T": {'letter': 'T', 'value': 1, 'freq': 3}, 
	"U": {'letter': 'U', 'value': 1, 'freq': 5}, 
	"V": {'letter': 'V', 'value': 4, 'freq': 1}, 
	"W": {'letter': 'W', 'value': 4, 'freq': 1}, 
	"X": {'letter': 'X', 'value': 8, 'freq': 1}, 
	"Y": {'letter': 'Y', 'value': 4, 'freq': 1}, 
	"Z": {'letter': 'Z', 'value': 10, 'freq': 1}
}

func create(config: Dictionary, type: Token.Type):
	var scene = TokenScene.instantiate()
	scene.type = type
	scene.letter = config.letter
	scene.value = config.value
	return scene

func create_starting_tokens() -> Array[Token]:
	var tokens = [] as Array[Token]
	for key in LETTERS.keys():
		var config = LETTERS[key]
		for i in config.freq:
			var scene = create(config, Token.Type.GRAPE)
			tokens.append(scene)
	return tokens
