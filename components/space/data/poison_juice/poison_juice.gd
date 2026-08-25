extends JuiceSpace
class_name PoisonJuiceSpace

func is_poison() -> bool:
	return true

func get_text_color() -> Color:
	return Color.WHITE

func get_badge_color() -> Color:
	return Color.BLACK
