extends RelicData
class_name StompedGrapes

@export var scale_by: float:
	set(v):
		scale_by = v
		current_value = 0

var current_value: int

func get_mult(context: RelicContext) -> int:
	return current_value

func on_token_destroyed(context: RelicContext) -> RelicResponse:
	if context.destroyed_token.is_vowel():
		_scale()
		return RelicResponse.UPGRADE
	return RelicResponse.NONE
	
func get_on_token_destroyed_text(response: RelicResponse) -> String:
	if response == RelicResponse.UPGRADE:
		return 'Squash!'
	return ''
	
func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (currently ' + str(current_value) + ')'

func _scale():
	current_value += scale_by
