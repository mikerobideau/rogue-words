extends ItemData
class_name Shears

func use_on_board(board, target) -> bool:
	if target == null or not board.has_method("remove_leaf"):
		return false
	board.remove_leaf(target)
	return true
