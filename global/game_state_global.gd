extends Node
class_name GameStateGlobal

signal money_changed(value: int)

var target_scores: Array[int] = [
	10, 130, 170, 220, 280,
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

var money: int = 0:
	set(v):
		money = v
		money_changed.emit(v)

var tokens: Array[TokenData]

var discarded_tokens: Array[TokenData]

var discards_per_round := 2

var relics: Array[RelicData]
