extends PanelContainer
class_name TooltipNode

@onready var label = $MarginContainer/Label

func set_text(text: String):
	label.text = text
	reset_size()
