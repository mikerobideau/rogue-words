extends RelicData
class_name Harvest

func _ready():
	count = 0

func on_score_event(context: RelicContext):
	_add_count(1)
	if count >= threshold:
		_reset_count()
		context.state.money += money_reward
		return true
	return false
