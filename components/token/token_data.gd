extends Resource
class_name TokenData

signal letter_changed()

const VOWELS = ['A', 'E', 'I', 'O', 'U']
const CONSONANTS = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']

@export var cost := 2
@export var sprite_frames: SpriteFrames
@export var letter: String
@export var value: int
@export var enhancement: TokenEnhancement

func enhance(e: TokenEnhancement):
	enhancement = e
	
func next_letter():
	var code = letter.to_upper().unicode_at(0)
	letter = char((code - 65 + 1) % 26 + 65)

func change_letter_to(l: String):
	letter = l
	value = TokenFactory.LETTERS[l].value
	letter_changed.emit()
	
func swap_random_consonant_vowel():
	if letter in VOWELS:
		letter = CONSONANTS[randi() % CONSONANTS.size()]
	else:
		letter = VOWELS[randi() % VOWELS.size()]
