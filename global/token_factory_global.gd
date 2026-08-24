extends Node
class_name TokenFactoryGlobal

var TokenScene = preload("res://components/token/token.tscn")
var LeafScene = preload("res://components/token/leaf_token.tscn")

const LETTERS: Dictionary = {
	"A": {'letter': 'A', 'value': 1}, 
	"B": {'letter': 'B', 'value': 3}, 
	"C": {'letter': 'C', 'value': 3}, 
	"D": {'letter': 'D', 'value': 2}, 
	"E": {'letter': 'E', 'value': 1}, 
	"F": {'letter': 'F', 'value': 4}, 
	"G": {'letter': 'G', 'value': 2}, 
	"H": {'letter': 'H', 'value': 4}, 
	"I": {'letter': 'I', 'value': 1}, 
	"J": {'letter': 'J', 'value': 8}, 
	"K": {'letter': 'K', 'value': 5}, 
	"L": {'letter': 'L', 'value': 1}, 
	"M": {'letter': 'M', 'value': 3}, 
	"N": {'letter': 'N', 'value': 1}, 
	"O": {'letter': 'O', 'value': 1}, 
	"P": {'letter': 'P', 'value': 3}, 
	"Q": {'letter': 'Q', 'value': 10}, 
	"R": {'letter': 'R', 'value': 1}, 
	"S": {'letter': 'S', 'value': 1}, 
	"T": {'letter': 'T', 'value': 1}, 
	"U": {'letter': 'U', 'value': 1}, 
	"V": {'letter': 'V', 'value': 4}, 
	"W": {'letter': 'W', 'value': 4}, 
	"X": {'letter': 'X', 'value': 8}, 
	"Y": {'letter': 'Y', 'value': 4}, 
	"Z": {'letter': 'Z', 'value': 10}
}

func create_by_letter(letter: String):
	var config = LETTERS[letter]
	var data = create_data(config)
	return create_scene(data)

func create_data_by_letter(letter: String) -> TokenData:
	var config = LETTERS[letter]
	return create_data(config)

func create_data(config: Dictionary) -> TokenData:
	var data = TokenData.new()
	data.letter = config.letter
	data.value = config.value
	return data

func create_scene(data: TokenData):
	var scene = TokenScene.instantiate()
	scene.data = data
	return scene

# a leaf is a random letter with no base juice -- the board grows these itself,
# they are never dealt to the player
func create_leaf(letters := TokenData.VOWELS) -> Token:
	var data = create_data_by_letter(letters.pick_random())
	data.value = 0
	var scene = LeafScene.instantiate()
	scene.data = data
	return scene
	
func load_all_tokens() -> Array[TokenData]:
	return create_starting_tokens()

func create_starting_tokens() -> Array[TokenData]:
	var tokens = [] as Array[TokenData]
	for key in LETTERS.keys():
		var config = LETTERS[key]
		var data = create_data(config)
		tokens.append(data)
	tokens.shuffle()
	return tokens
