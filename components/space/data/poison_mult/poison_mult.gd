extends MultSpace
class_name PoisonMultSpace

func is_poison() -> bool:
	return true

func get_text_color() -> Color:
	return Color(Styles.PINK)

func get_badge_color() -> Color:
	return Color.BLACK
