extends SpaceData
class_name MultSpace

@export var mult: int
@export var color: Color

func get_mult() -> int:
	return mult
	
func get_badge_text() -> String:
	return str(mult)
	
func get_label_text() -> String:
	return str(mult) + ' mult'
