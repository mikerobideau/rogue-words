extends Node2D
class_name Scorer

func score(word:Dictionary) -> ScoreEvent:
	var event = ScoreEvent.new()
	event.path = word.path
	event.word = word.word
	event.score = _path_to_score(word.path)
	return event
	
func _path_to_score(path: Array) -> int:
	var values = path.map(func(p): return p.token.value)
	return values.reduce(func(acc, n): return acc + n, 0)
