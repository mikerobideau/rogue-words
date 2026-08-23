extends Token
class_name LeafToken

func _ready():
	super()
	is_selectable = false

func on_placed():
	Sound.play(Sound.SOUND_TOKEN_PLACED)
	_animate_placed()
	is_selectable = false

func get_tooltip_text():
	return 'Leaf ' + data.letter + ' (0)'
