extends Node
class_name GameStateGlobal

signal money_changed(value: int)

var target_scores: Array[int] = [
	50, 75, 125, 200, 280,
	350, 430, 520, 620, 730,
	860, 1000, 1150, 1320, 1500,
	1700, 1950, 2250, 2600, 3000, 3500
]

var target_score: int

var round_number := 0:
	set(v):
		round_number = v
		target_score = target_scores[v - 1]
		discarded_tokens = [] as Array[TokenData]
		is_boss_round = round_number % 3 == 0
		current_boss = BossFactory.random_boss_data() if is_boss_round else BossData.new()

var money: int:
	set(v):
		money = v
		money_changed.emit(v)

var tokens: Array[TokenData]

var discarded_tokens: Array[TokenData]

var relics: Array[RelicData]

var items: Array[ItemData]

var current_boss: BossData
var is_boss_round: bool
