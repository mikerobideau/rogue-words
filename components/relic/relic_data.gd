extends Resource
class_name RelicData

signal data_changed()
signal scaled(v: int)

enum RelicResponse {
	NONE,
	UPGRADE,
	SCORE,
	DECAY,
	RESET_NEGATIVE,
	RESET_POSITIVE
}

@export var relic_name: String
@export var description: String
@export var cost := 5

#---------------------------------------------------------------------------------------------------
# Board Events
#---------------------------------------------------------------------------------------------------

func on_token_placed(context: RelicContext) -> bool:
	return false
	
func add_grow_amount(context: RelicContext) -> int:
	return 0
	
#---------------------------------------------------------------------------------------------------
# Word Detection
#---------------------------------------------------------------------------------------------------
func modify_letter_matches(letter: String, matches: Array) -> Array:
	return matches

#---------------------------------------------------------------------------------------------------
# Scoring Events
#---------------------------------------------------------------------------------------------------

func before_score(context: RelicContext) -> RelicResponse:
	return RelicResponse.NONE

func get_before_score_text(response: RelicResponse) -> String:
	return ''

func get_score_report(context: RelicContext) -> RelicReportItem:
	var score = get_score(context)
	if score == -1: #Relic condition not met
		return null
	var report = RelicReportItem.new()
	report.relic = context.relic
	report.prev_score = context.word_score
	report.new_score = score
	report.text = get_score_text(context)
	return report

func get_score_text(context: RelicContext):
	return ''

func get_score(context: RelicContext) -> int:
	return -1
	
#---------------------------------------------------------------------------------------------------
# Round Events
#---------------------------------------------------------------------------------------------------
	
func on_discard(context: RelicContext) -> RelicResponse:
	return RelicResponse.NONE
	
func get_discard_text(response: RelicResponse) -> String:
	return ''
	
func on_round_complete(context: RelicContext) -> bool:
	return false
	
#---------------------------------------------------------------------------------------------------
# Information
#---------------------------------------------------------------------------------------------------
	
func get_tooltip_text():
	return description
