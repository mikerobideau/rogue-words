extends Resource
class_name RelicData

signal data_changed()

@export var relic_name: String
@export var description: String
@export var scale_by: int

var bonus := 0

func on_token_placed(context: RelicContext) -> bool:
	return false

func on_score_event(context: RelicContext) -> bool:
	return false
	
func add_grow_amount(context: RelicContext) -> int:
	return 0
	
func _add_bonus(v: int):
	bonus += v
	data_changed.emit()
