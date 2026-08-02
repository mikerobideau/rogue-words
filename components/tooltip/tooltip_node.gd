extends PanelContainer
class_name TooltipNode

@onready var label = $Label

func set_text(text: String):
	label.text = text
	#await get_tree().process_frame
	#print_debug(str(label.size.x))
	#size.x = label.size.x
	#reset_size()
