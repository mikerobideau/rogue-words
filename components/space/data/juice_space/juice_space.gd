extends SpaceData
class_name JuiceSpace

@export var juice: int
@export var color: Color

func get_juice() -> int:
	return juice

func get_text_color() -> Color:
	return color

func get_badge_color() -> Color:
	return color

func get_badge_text() -> String:
	return str(juice)
	
func get_label_text() -> String:
	return str(juice) + ' juice'
