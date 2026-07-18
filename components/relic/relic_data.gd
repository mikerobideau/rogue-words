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
	RESET_POSITIVE,
	EVENT,
	MONEY_REWARD,
	COUNTDOWN
}

const COST_BY_RARITY = {
	Rarity.Type.COMMON: 5,
	Rarity.Type.UNCOMMON: 7,
	Rarity.Type.RARE: 10,
	Rarity.Type.LEGENDARY: 15
}

@export var relic_name: String
@export var description: String
@export var rarity: Rarity.Type
	
var cost: int:
	get: return COST_BY_RARITY[rarity]

#---------------------------------------------------------------------------------------------------
# Labels
#---------------------------------------------------------------------------------------------------
	
func get_tooltip_text(context: RelicContext):
	return description

#---------------------------------------------------------------------------------------------------
# Token Events
#---------------------------------------------------------------------------------------------------

func on_token_destroyed(context: RelicContext) -> RelicResponse:
	return RelicResponse.NONE
	
func get_on_token_destroyed_text(response: RelicResponse) -> String:
	return ''

#---------------------------------------------------------------------------------------------------
# Board Events
#---------------------------------------------------------------------------------------------------

func on_token_placed(context: RelicContext) -> RelicResponse:
	return RelicResponse.NONE
	
func get_on_placed_text(response: RelicResponse) -> String:
	return ''
	
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
