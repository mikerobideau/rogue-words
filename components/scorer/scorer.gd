extends Node2D
class_name Scorer

func score(path: Array) -> ScoreEvent:
	var event = ScoreEvent.new()
	event.path = path
	event.word = _path_to_word(path)
	event.score = _path_to_score(path)
	return event

func _path_to_word(paths: Array):
	var letters = paths.map(func(p): return p.token.letter)
	return ''.join(letters)
	
func _path_to_score(path: Array) -> int:
	var values = path.map(func(p): return p.token.value)
	return values.reduce(func(acc, n): return acc + n, 0)
