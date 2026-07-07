extends RelicData
class_name Chameleon

func modify_letter_matches(letter: String, matches: Array):
	if letter == 'C' and 'CH' not in matches:
		matches.append('CH')
	return matches
