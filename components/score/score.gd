extends Label
class_name Score

@export var target_score: int = 0:
	set(v):
		target_score = v
		if is_node_ready():
			_update_label()
		else:
			push_warning('Score tried to set update label before node was ready')

var value := 0

func _ready():
	_update_label()

func add(v: int):
	value += v
	_update_label()
	
func _update_label():
		text = str(value) + ' / ' + str(target_score) 
