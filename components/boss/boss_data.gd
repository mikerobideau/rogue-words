extends Resource
class_name BossData

@export var boss_name: String
@export var description: String
	
func get_discards(base: int) -> int:
	return base
