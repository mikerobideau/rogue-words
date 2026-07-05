extends Control
class_name Money

@onready var label = $Label

func _ready():
	GameState.money_changed.connect(_update_label)
	
func _update_label(value: int):
	label.text = str(value)
