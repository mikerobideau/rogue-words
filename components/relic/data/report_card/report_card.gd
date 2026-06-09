extends RelicData
class_name ReportCard

@export var amount: int

var count := 0

func on_token_placed(context: RelicContext) -> bool:
	if context.placed_token.letter in ['B', 'C', 'D', 'F']:
		count = 0
		return false
	if context.placed_token.letter == 'A':
		count += 1
		if count >= 5:
			context.state.money += amount
			count = 0
			return true
	return false
