extends RelicData
class_name Queue

@export var mult: int

func get_mult(context: RelicContext) -> int:
	return _count_qs(context.hand) * mult

func _count_qs(hand: Array[Token]) -> int:
	var count = 0
	for token in hand:
		if token.data.letter == 'Q':
			count += 1
	return count
