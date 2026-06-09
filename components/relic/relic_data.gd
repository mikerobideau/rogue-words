extends Resource
class_name RelicData

@export var relic_name: String
@export var description: String

func on_token_placed(context: RelicContext) -> bool:
	return false

func on_score_event(context: RelicContext) -> bool:
	return false
	
func add_grow_amount(context: RelicContext) -> int:
	return 0
