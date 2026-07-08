extends RelicData
class_name Chameleon

#detect if word contains a C -> CH
#note this part is only neeed to make the relic animate/play a sound
func on_score_event(context: RelicContext) -> bool:
	for lr in context.word_report.letter_reports:
		if lr.space == null:
			continue
		var base = lr.space.token.letter
		if lr.display_letter != base and modify_letter_matches(base, [base]).has(lr.display_letter):
			return true
	return false

func modify_letter_matches(letter: String, matches: Array):
	if letter == 'C' and 'CH' not in matches:
		matches.append('CH')
	return matches
