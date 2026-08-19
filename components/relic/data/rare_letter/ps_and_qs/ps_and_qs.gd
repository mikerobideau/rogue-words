extends RelicData
class_name PsAndQs

func on_token_placed(context: RelicContext):
	var token = context.placed_token
	if token.letter == 'P':
		token.data.change_letter_to('Q')
		return RelicResponse.EVENT
	return RelicResponse.NONE
	
func get_on_placed_text(response: RelicResponse):
	if response == RelicResponse.EVENT:
		return 'Behave!'
	return ''
