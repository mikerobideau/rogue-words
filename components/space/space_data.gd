extends Resource
class_name SpaceData

enum Type {
	STANDARD,
	TRIPLE_LETTER,
	DOUBLE_WORD
}

@export var type: Type

func modify_letter_score(v: int) -> int:
	if type == Type.TRIPLE_LETTER:
		return v * 3
	return v

func type_label():
	match type:
		Type.STANDARD: return ''
		Type.TRIPLE_LETTER: return 'Letter x3'
		Type.DOUBLE_WORD: return 'Word x2'

func get_word_mult():
	match type:
		Type.DOUBLE_WORD:
			return 2
		_:
			return 1

func has_letter_effect():
	match type:
		Type.TRIPLE_LETTER:
			return true
		_:
			return false
			
func has_enhancement():
	return type != Type.STANDARD
