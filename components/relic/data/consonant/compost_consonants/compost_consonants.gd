extends RelicData
class_name CompostConsonants

@export var scale_by: int
@export var threshold: int

var current_value := 0
var last_gain := 0
var count := 0

func get_juice(context: RelicContext) -> int:
	return count / threshold * scale_by #note integer division automatically floors, which is correct here

func get_discard_text(response: RelicResponse) -> String:
	return '+' + str(last_gain)

func get_tooltip_text(context: RelicContext):
	return description + ' (currently +' + str(get_juice(context)) + ')'

func on_discard(context: RelicContext) -> RelicResponse:
	var num_consonants := 0
	for token in context.discarded_tokens:
		if token.data.is_consonant():
			num_consonants += 1
	var before := get_juice(context)
	count += num_consonants
	last_gain = get_juice(context) - before
	if last_gain > 0:
		return RelicResponse.UPGRADE
	return RelicResponse.NONE

func _scale(value: int):
	current_value += value
