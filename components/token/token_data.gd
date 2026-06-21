extends Resource
class_name TokenData

enum Type {
	GRAPE,
	GREEN_GRAPE,
	YELLOW_GRAPE,
	CLOVER
}

const VOWELS = ['A', 'E', 'I', 'O', 'U']
const CONSONANTS = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']

@export var type: Type
@export var cost := 2
@export var letter: String
@export var value: int

func enhance(t: TokenData.Type):
	type = t
	
func next_letter():
	var code = letter.to_upper().unicode_at(0)
	letter = char((code - 65 + 1) % 26 + 65)
	
func swap_random_consonant_vowel():
	if letter in VOWELS:
		letter = CONSONANTS[randi() % CONSONANTS.size()]
	else:
		letter = VOWELS[randi() % VOWELS.size()]

func has_score_enhancement():
	match Type:
		Type.YELLOW_GRAPE:
			return true
		_:
			return false
