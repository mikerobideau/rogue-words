extends RelicData
class_name Chameleon

#detect if word contains a C -> CH
#note this part is only neeed to make the relic animate/play a sound
func before_score(context: RelicContext) -> RelicResponse:
	for tile in context.word_score.tiles:
		var space = tile.space
		if space == null:
			continue
		var base = space.token.letter
		if tile.display_letter != base and modify_letter_matches(base, [base]).has(tile.display_letter):
			return RelicResponse.EVENT
	return RelicResponse.NONE

func modify_letter_matches(letter: String, matches: Array):
	if letter == 'C' and 'CH' not in matches:
		matches.append('CH')
	return matches
