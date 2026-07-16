extends RelicData
class_name HealthInspection

@export var scale_by: int

var current_value := 0

func on_token_placed(context: RelicContext) -> RelicResponse:
	if context.placed_token.letter == 'A':
		_scale()
		return RelicResponse.UPGRADE
	if context.placed_token.letter in ['B', 'C', 'D', 'F']:
		_reset()
		return RelicResponse.RESET_NEGATIVE
	return RelicResponse.NONE
		
func get_score(context: RelicContext) -> int:
	if current_value > 0:
		return context.word_score + current_value
	return -1
	
func get_score_text(context: RelicContext) -> String:
	return 'Straight A\'s +' + str(current_value)

func get_on_placed_text(response: RelicResponse) -> String:
	if response == RelicResponse.UPGRADE:
		return 'Passed!'
	if response == RelicResponse.RESET_NEGATIVE:
		return 'Failed'
	return ''
	
func get_tooltip_text() -> String:
	return description + ' (currently ' + str(current_value) + ')'

func _scale():
	current_value += scale_by
	
func _reset():
	current_value = 0
