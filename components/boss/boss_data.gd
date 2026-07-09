extends Resource
class_name BossData

@export var boss_name: String
@export var description: String
	
func get_discards(base: int) -> int:
	return base

func get_hand_size(base: int) -> int:
	return base

func get_min_word_length(base: int) -> int:
	return base

func get_starting_board_size(base: int) -> int:
	return base
