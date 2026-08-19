extends RelicData
class_name Banana

@export var mult: int

func get_mult(context: RelicContext) -> int:
	if _has_at_least_three_of_a_letter(context.word):
		return mult
	return 0

func _has_at_least_three_of_a_letter(word: String) -> bool:
	var counts := {}
	for c in word.to_upper():
		counts[c] = counts.get(c, 0) + 1
		if counts[c] >= 3:
			return true
	return false
