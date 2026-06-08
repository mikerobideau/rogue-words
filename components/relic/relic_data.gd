extends Resource
class_name RelicData

@export var relic_name: String
@export var description: String

func on_token_placed(context: RelicContext):
	return false

func on_score_event(context: RelicContext):
	return false
