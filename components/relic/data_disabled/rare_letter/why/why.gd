extends RelicData
class_name Why

func on_token_placed(context: RelicContext):
	if context.placed_token.data.letter == 'Y':
		var token_data = TokenFactory.create_data_by_letter('Y')
		GameState.add_token(token_data)
		return true
	return false
