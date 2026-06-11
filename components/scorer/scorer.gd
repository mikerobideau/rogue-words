extends Node2D
class_name Scorer

func score(word:Dictionary) -> ScoreEvent:
	var event = ScoreEvent.new()
	event.path = word.path
	event.word = word.word
	event.base = _path_to_base_score(word.path)
	event.mult = _path_to_mult(word.path)
	event.score = event.base * event.mult
	return event
	
func _path_to_base_score(path: Array) -> int:
	var values = path.map(func(p): return p.token.value)
	return values.reduce(func(acc, n): return acc + n, 0)

func _path_to_mult(path: Array) -> int:
	var mult = 1
	for space in path:
		if space.token.type == Token.Type.YELLOW_GRAPE:
			mult *= 2
	print_debug('mult is ' + str(mult))
	return mult
