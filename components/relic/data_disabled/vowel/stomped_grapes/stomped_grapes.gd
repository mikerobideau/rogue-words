extends RelicData
class_name StompedGrapes

@export var scale_by: float:
	set(v):
		scale_by = v
		current_value = 1

var current_value: float

func on_token_destroyed(context: RelicContext) -> RelicResponse:
	if context.destroyed_token.is_vowel():
		_scale()
		return RelicResponse.UPGRADE
	return RelicResponse.NONE
	
func get_on_token_destroyed_text(response: RelicResponse) -> String:
	if response == RelicResponse.UPGRADE:
		return 'Squash!'
	return ''
	
func get_score(context: RelicContext) -> int:
	if current_value > 1:
		return context.word_score * current_value
	return -1

func get_score_text(context: RelicContext) -> String:
	if current_value > 1:
		return 'Squash! x' + str(current_value)
	return '' 
	
func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (currently x' + str(current_value) + ')'

func _scale():
	current_value += scale_by
