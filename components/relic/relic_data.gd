extends Resource
class_name RelicData

signal data_changed()

@export var relic_name: String
@export var description: String
@export var cost := 5
@export var scale_by: int
@export var threshold: int
@export var money_reward: int
@export var has_bonus := false
@export var has_count := false

var bonus := 0
var count := 0

func get_score_report(context: RelicContext) -> RelicReportItem:
	var report = RelicReportItem.new()
	report.relic = context.relic
	report.prev_score = context.word_score
	report.new_score = get_score(context)
	report.text = get_text(context)
	return report

func get_score(context: RelicContext) -> int:
	return context.word_score
	
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
	
func _add_bonus(v: int):
	bonus += v
	data_changed.emit()
	
func _add_count(v: int):
	count += v
	data_changed.emit()
	
func _reset_count():
	count = 0
	data_changed.emit()
