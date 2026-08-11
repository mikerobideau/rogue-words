extends RelicData
class_name DiedOnTheVine

func on_token_placed(context: RelicContext) -> RelicResponse:
	if context.turn_number == 1:
		await context.placed_token.destroy()
		return RelicResponse.EVENT
	return RelicResponse.NONE

func get_on_placed_text(response: RelicResponse) -> String:
	return 'Farewell!'
