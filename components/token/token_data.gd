extends Resource
class_name TokenData

signal letter_changed()
signal value_changed()

#note that Y counts as both a vowel and a consonant
const VOWELS = ['A', 'E', 'I', 'O', 'U', 'Y']
const CONSONANTS = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']

@export var cost := 2
@export var sprite_frames: SpriteFrames
@export var letter: String
@export var value: int
@export var enhancement: TokenEnhancement

var spent := false

func enhance(e: TokenEnhancement):
	Tooltip.hide_for_node()
	if e:
		enhancement = e
		e.charged.connect(_on_charged)

func get_title():
	return enhancement.enhancement_name if enhancement else 'Grape'
		
func next_letter():
	var code = letter.to_upper().unicode_at(0)
	letter = char((code - 65 + 1) % 26 + 65)
	letter_changed.emit()

func change_letter_to(l: String):
	letter = l
	value = TokenFactory.LETTERS[l].value
	letter_changed.emit()
	
func swap_random_consonant_vowel():
	if letter in VOWELS:
		letter = CONSONANTS[randi() % CONSONANTS.size()]
	else:
		letter = VOWELS[randi() % VOWELS.size()]
	letter_changed.emit()
	
func is_vowel():
	return letter in VOWELS
	
func is_consonant():
	return letter in CONSONANTS

func _on_charged():
	value += 1
	value_changed.emit()
