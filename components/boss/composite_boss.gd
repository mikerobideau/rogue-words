extends BossData
class_name CompositeBoss

var bosses: Array = []

func get_difficulty() -> int:
	var total := 0
	for b in bosses:
		total += b.get_difficulty()
	return total

func get_discards(base: int) -> int:
	var v := base
	for b in bosses:
		v = b.get_discards(v)
	return v

func get_hand_size(base: int) -> int:
	var v := base
	for b in bosses:
		v = b.get_hand_size(v)
	return v

func get_min_word_length(base: int) -> int:
	var v := base
	for b in bosses:
		v = b.get_min_word_length(v)
	return v

func get_starting_board_size(base: int) -> int:
	var v := base
	for b in bosses:
		v = b.get_starting_board_size(v)
	return v

func get_turns_per_round(base: int) -> int:
	var v := base
	for b in bosses:
		v = b.get_turns_per_round(v)
	return v

func get_leaves_per_round(base: int) -> int:
	var v := base
	for b in bosses:
		v = b.get_leaves_per_round(v)
	return v

func get_token_value(base: int, letter: String) -> int:
	var v := base
	for b in bosses:
		v = b.get_token_value(v, letter)
	return v

func get_target_score(base: int) -> int:
	var v := base
	for b in bosses:
		v = b.get_target_score(v)
	return v

func get_disabled_relic_count() -> int:
	var total := 0
	for b in bosses:
		total += b.get_disabled_relic_count()
	return total

func get_poisoned_space_count() -> int:
	var total := 0
	for b in bosses:
		total += b.get_poisoned_space_count()
	return total

func on_turn_scored(board) -> void:
	for b in bosses:
		b.on_turn_scored(board)
