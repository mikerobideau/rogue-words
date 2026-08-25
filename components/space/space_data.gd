extends Resource
class_name SpaceData

@export var has_badge := false
@export var sprite_frames: SpriteFrames

func is_poison() -> bool:
	return false

func get_text_color() -> Color:
	return Color.WHITE

func get_badge_color() -> Color:
	return Color.WHITE

func get_juice() -> int:
	return 0

func get_mult() -> int:
	return 0

func get_badge_text() -> String:
	return ''

func get_label_text() -> String:
	return ''
