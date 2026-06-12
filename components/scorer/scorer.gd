extends Node2D
class_name Scorer

func get_word_report(found_word: Dictionary):
	var report = WordReport.new()
	report.word = found_word.word
	report.spaces = found_word.path
	report.letter_reports = [] as Array[LetterReport] 
	var score = 0
	for space in report.spaces:
		var letter_report = _get_letter_report(space)
		report.letter_reports.append(letter_report)
		score += letter_report.score
	report.score = score
	return report

func _get_letter_report(space: Space):
	var report = LetterReport.new()
	var token = space.token
	report.letter = token.letter
	report.space = space
	var score = token.value
	var mult := _mult_enhancement(space)
	
	#note that letter can only have mult OR plus, but not both
	if mult > 1:
		score *= mult
		var bonus_label = 'x' + str(mult)
	else:
		var plus := _plus_enhancement(space)
		if plus > 0:
			score += plus
			var bonus_label = '+' + str(plus)
	report.score = score
	return report
	
func _mult_enhancement(space: Space) -> int:
	if space.token.type == Token.Type.YELLOW_GRAPE:
		return 2
	return 1

func _plus_enhancement(space: Space) -> int:
	return 0

func score(word: Dictionary) -> ScoreEvent:
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
	return mult
