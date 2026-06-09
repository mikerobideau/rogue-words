extends Node
class_name GameStateGlobal

signal money_changed(value: int)

var round_number := 0

var money: int = 0:
	set(v):
		money = v
		print_debug('money changed to ' + str(v))
		money_changed.emit(v)
