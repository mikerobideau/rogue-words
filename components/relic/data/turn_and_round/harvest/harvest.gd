extends RelicData
class_name Harvest

@export var money_reward: int
@export var threshold: int

var count: int

func _ready():
	count = 0

func before_score(context: RelicContext):
	count += 1
	if count >= threshold:
		count = 0
		GameState.money += money_reward
		return RelicResponse.MONEY_REWARD
	return RelicResponse.NONE
	
func get_before_score_text(response: RelicResponse) -> String:
	return '+$' + str(money_reward)
