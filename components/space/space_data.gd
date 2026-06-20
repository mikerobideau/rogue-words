extends Resource
class_name SpaceData

enum Type {
	STANDARD,
	DOUBLE_LETTER,
	DOUBLE_WORD
}

@export var type: Type

func modify_letter_score(v: int) -> int:
	if type == Type.DOUBLE_LETTER:
		return v * 2
	return v

func type_label():
	match type:
		Type.STANDARD: return ''
		Type.DOUBLE_LETTER: return 'Letter x2'
		Type.DOUBLE_WORD: return 'Word x2'

func get_word_mult():
	match type:
		Type.DOUBLE_WORD:
			return 2
		_:
			return 1

func has_letter_effect():
	match type:
		Type.DOUBLE_LETTER:
			return true
		_:
			return false
