extends RelicData
class_name PsAndQs

func on_token_placed(context: RelicContext):
	var token = context.placed_token
	if token.letter == 'P':
		token.data.change_letter_to('Q')
		return true
	return false
