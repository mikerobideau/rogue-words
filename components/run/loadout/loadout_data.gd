@tool
extends Resource
class_name LoadoutData

@export var loadout_name: String
@export var tiles: Array[TileFrequency]

func _init() -> void:
	if tiles.is_empty():
		for letter in TokenFactoryGlobal.LETTERS.keys():
			var entry := TileFrequency.new()
			entry.letter = letter
			entry.count = 1
			tiles.append(entry)

func create_starting_tokens() -> Array[TokenData]:
	var tokens: Array[TokenData] = []
	for entry in tiles:
		if entry == null or not TokenFactory.LETTERS.has(entry.letter):
			continue
		for i in entry.count:
			tokens.append(TokenFactory.create_data_by_letter(entry.letter))
	tokens.shuffle()
	return tokens
