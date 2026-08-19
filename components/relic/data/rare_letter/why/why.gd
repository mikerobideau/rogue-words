extends RelicData
class_name Why

func on_token_placed(context: RelicContext):
	if context.placed_token.letter == 'Y':
		var token_data = TokenFactory.create_data_by_letter('Y')
		GameState.add_token(token_data)
		return RelicResponse.EVENT
	return RelicResponse.EVENT
	
func get_on_placed_text(response: RelicResponse):
	return 'Why?'
