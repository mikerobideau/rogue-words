extends RelicData
class_name Chameleon

#detect if word contains a C -> CH
#note this part is only neeed to make the relic animate/play a sound
func on_score_event(context: RelicContext) -> bool:
	print_debug('on_score_event for word ' + context.word)
	for lr in context.word_report.letter_reports:
		if lr.space == null:
			continue
		var base = lr.space.token.letter
		print_debug('base is ' + base + ' and display letter is ' + lr.display_letter)
		if lr.display_letter != base and modify_letter_matches(base, [base]).has(lr.display_letter):
			print_debug('returning true')
			return true
	return false

func modify_letter_matches(letter: String, matches: Array):
	if letter == 'C' and 'CH' not in matches:
		matches.append('CH')
	return matches
