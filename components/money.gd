extends MarginContainer
class_name Money

@onready var label = $Label

func _ready():
	GameState.money_changed.connect(_update_label)
	
func _update_label(value: int):
	print_debug('update money label')
	label.text = '$' + str(value)
