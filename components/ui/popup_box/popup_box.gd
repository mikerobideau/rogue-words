extends PanelContainer
class_name PopupBox

@onready var label = $Label

func set_text(text: String):
	label.text = text
