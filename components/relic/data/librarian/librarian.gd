extends RelicData
class_name Librarian

func modify_letter_matches(letter: String, matches: Array):
	if letter == 'S' and 'SH' not in matches:
		matches.append('SH')
	return matches
