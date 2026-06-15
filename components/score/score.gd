extends MarginContainer
class_name Score

@onready var label = $Label

@export var target_score: int = 0:
	set(v):
		target_score = v
		if is_node_ready():
			_update_label()
		else:
			push_warning('Score tried to update label before node was ready')

var value := 0:
	set(v):
		value = v
		_update_label()

func _ready():
	_update_label()

func add(v: int):
	value += v
	_update_label()
	
func _update_label():
		label.text = str(value) + ' / ' + str(target_score) 
