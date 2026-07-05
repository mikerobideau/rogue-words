extends Node2D
class_name Scorer

func get_word_report(found_word: Dictionary):
	var report = WordReport.new()
	report.word = found_word.word
	report.spaces = found_word.path
	report.letter_reports = [] as Array[LetterReport]
	var running_score = 0
	for space in report.spaces:
		var letter_report = _get_letter_report(space, running_score)
		report.letter_reports.append(letter_report)
		running_score = letter_report.score
	
	var word_mult = _get_word_mult(report.spaces)
	if word_mult > 1:
		var new_score = running_score * word_mult
		report.word_mult_report = _make_word_mult_report(running_score, new_score, 'Word x' + str(word_mult))
		running_score = new_score
		
	report.score = running_score
	return report

func _get_letter_report(space: Space, running_score: int):
	var report = LetterReport.new()
	var token = space.token
	report.letter = token.letter
	report.space = space
	report.items = [] as  Array[LetterReportItem]
	
	#Token & space score. Added to running total
	var letter_value = space.modify_letter_score(token.value)
	var score = running_score + letter_value
	var token_text = space.data.type_label() if space.data.has_letter_effect() else ''
	report.items.append(_make_letter_item(running_score, score, token_text, space.data.has_letter_effect(), false))

	#Enhanced token score - modifies running total
	#Note that letter can only have mult OR plus, but not both
	
	#var mult := _mult_enhancement(space)
	#if mult > 1:
	#	var new_score = score * mult
	#	var text = 'x' + str(mult)
	#	report.items.append(_make_letter_item(score, new_score, text, false, true))
	#	score = new_score
	#else:
	#	var plus := _plus_enhancement(space)
	#	if plus > 0:
	#		var new_score = score + plus
	#		var text = '+' + str(plus)
	#		report.items.append(_make_letter_item(score, new_score, text, false, true))
	#		score = new_score
	
	report.score = score
	return report
	
#e.g., double word score space
func _get_word_mult(spaces: Array) -> int:
	var mult = 1
	for space in spaces:
		mult *= space.data.get_word_mult()
	return mult
	
func _make_letter_item(prev: int, new: int, text: String, is_enhanced_space: bool, is_enhanced_token: bool) -> LetterReportItem:
	var item = LetterReportItem.new()
	item.prev_score = prev
	item.new_score = new
	item.text = text
	item.is_enhanced_space = is_enhanced_space
	item.is_enhanced_token = is_enhanced_token
	return item
	
func _make_word_mult_report(prev: int, new: int, text: String) -> WordMultReport:
	var item = WordMultReport.new()
	item.prev_score = prev
	item.new_score = new
	item.text = text
	return item
	
#func _mult_enhancement(space: Space) -> int:
#	if space.token.type == TokenData.Type.SPICY_GRAPE:
#		return 2
#	return 1

#func _plus_enhancement(space: Space) -> int:
#	return 0

func _path_to_base_score(path: Array) -> int:
	var values = path.map(func(p): return p.token.value)
	return values.reduce(func(acc, n): return acc + n, 0)

func _path_to_mult(path: Array) -> int:
	var mult = 1
	for space in path:
		if space.token.data.enhancement:
			mult *= space.token.data.enhancement.get_mult()
	return mult
