extends RelicData
class_name PottyMouth

@export var scale_by: int

var current_value: int

func before_score(context: RelicContext) -> RelicResponse:
	if context.word.length() == 4:
		_scale()
		return RelicResponse.UPGRADE
	return RelicResponse.NONE

func get_score(context: RelicContext) -> int:
	if current_value > 0:
		return context.word_score + current_value
	return -1
	
func get_before_score_text(response: RelicResponse):
	if response == RelicResponse.UPGRADE:
		return '+' + str(scale_by)
	return ''
	
func get_score_text(context: RelicContext) -> String:
	return  '$#*! +' + str(current_value)

func get_tooltip_text(context: RelicContext) -> String:
	return description + ' (currently ' + str(current_value) + ')'

func _scale():
	current_value += scale_by
