extends Node
class_name GameStateGlobal

signal money_changed(value: int)

var round_number := 0

var money: int = 0:
	set(v):
		money = v
		money_changed.emit(v)

var tokens: Array[Token]
var discarded_tokens: Array[Token]
var discards_per_round := 2
