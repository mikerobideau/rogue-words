extends RelicData
class_name Alphabetical

@export var mult: int

func get_mult(context: RelicContext) -> int:
	if _is_alphabetical(context.word):
		return mult
	return 0

func _is_alphabetical(word: String) -> bool:
	var upper := word.to_upper()
	for i in range(1, upper.length()):
		if upper[i] < upper[i - 1]:
			return false
	return true
