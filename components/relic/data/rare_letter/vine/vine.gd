extends RelicData
class_name Vine

@export var scale_by: int

var current_value := 0

func get_juice(context: RelicContext) -> int:
	return current_value

func on_token_placed(context: RelicContext) -> int:
	if context.placed_token.letter == 'V':
		current_value += scale_by
		return RelicResponse.UPGRADE
	return RelicResponse.NONE
		
func get_on_placed_text(response: RelicResponse) -> String:
	if response == RelicResponse.UPGRADE:
		return '+' + str(scale_by)
	return ''
	
func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (currently ' + str(current_value) + ')'
