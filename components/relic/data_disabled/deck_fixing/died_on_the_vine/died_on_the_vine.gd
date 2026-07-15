extends RelicData
class_name DiedOnTheVine

func on_token_placed(context: RelicContext) -> bool:
	if context.turn_number == 1:
		await context.placed_token.destroy()
		return true
	return false
