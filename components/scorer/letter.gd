extends MarginContainer
class_name Letter

@onready var label = $Label

@export var letter: String:
	set(v):
		letter = v
		_update_label()
		
func _ready():
	_update_label()
		
func _update_label():
	if label:
		label.text = letter
