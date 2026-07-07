extends Resource
class_name RelicData

signal data_changed()

@export var relic_name: String
@export var description: String
@export var cost := 5
@export var is_scaling := false
@export var scale_by: int
@export var is_x_scaling := false
@export var x_scale_by: float
@export var money_reward: int
@export var has_count := false
@export var threshold: int

var scaling_value: int = 0
var x_scaling_value: float = 1.0
var count: int = 0

func get_score_report(context: RelicContext) -> RelicReportItem:
	var score = get_score(context)
	if score == -1: #Relic condition not met
		return null
	var report = RelicReportItem.new()
	report.relic = context.relic
	report.prev_score = context.word_score
	report.new_score = score
	report.text = get_text(context)
	return report

func get_score(context: RelicContext) -> int:
	return -1
	
func get_text(context: RelicContext):
	return ''

func on_token_placed(context: RelicContext) -> bool:
	return false

func on_score_event(context: RelicContext) -> bool:
	return false
	
func add_grow_amount(context: RelicContext) -> int:
	return 0
	
func modify_letter_matches(letter: String, matches: Array) -> Array:
	return matches
	
func on_round_complete(context: RelicContext) -> bool:
	return false
	
func _add_scaling_value(v: int):
	scaling_value += v
	data_changed.emit()
	
func _add_x_scaling_value(v: float):
	x_scaling_value += v
	data_changed.emit()
	
func _add_count(v: int):
	count += v
	data_changed.emit()
	
func _reset_count():
	count = 0
	data_changed.emit()
