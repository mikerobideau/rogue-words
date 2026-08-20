extends TextureButton
class_name ButtonDefault

@onready var label = $Label

@export var text: String:
	set(v):
		text = v
		if is_node_ready():
			label.text = v
			
func _ready():
	if text:
		label.text = text
