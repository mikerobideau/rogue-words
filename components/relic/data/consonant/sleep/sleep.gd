extends RelicData
class_name Sleep

@export var bonus: int

var z_count := 0

func get_juice(context: RelicContext) -> int:
	#print_debug(str(_get_z_count())
	return bonus * _get_z_count(context.tokens)
	
func _get_z_count(tokens: Array[TokenData]) -> int:
	var count := 0
	for token in tokens:
		if token.letter == 'Z':
			count += 1
	return count

func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (currently +' + str(_get_z_count(context.tokens)) + ')'
