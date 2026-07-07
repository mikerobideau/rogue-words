extends RelicData
class_name Queue

func get_score(context: RelicContext) -> int:
	var q_count = _count_qs(context.hand)
	if q_count > 0:
		return context.word_score * 1.5 * q_count
	return -1
	
func get_text(context: RelicContext) -> String:
	return 'Queue x' + str(1.5 * _count_qs(context.hand))

func _count_qs(hand: Array[Token]) -> int:
	var count = 0
	for token in hand:
		if token.data.letter == 'Q':
			count += 1
	return count
