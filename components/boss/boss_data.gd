extends Resource
class_name BossData

@export var boss_name: String
@export var description: String
@export var difficulty := 1

func get_difficulty() -> int:
	return difficulty

func get_discards(base: int) -> int:
	return base

func get_hand_size(base: int) -> int:
	return base

func get_min_word_length(base: int) -> int:
	return base

func get_starting_board_size(base: int) -> int:
	return base

func get_turns_per_round(base: int) -> int:
	return base

func get_leaves_per_round(base: int) -> int:
	return base

func get_token_value(base: int, letter: String) -> int:
	return base

func get_disabled_relic_count() -> int:
	return 0

func get_target_score(base: int) -> int:
	return base

func get_poisoned_space_count() -> int:
	return 0

func on_turn_scored(board) -> void:
	pass
