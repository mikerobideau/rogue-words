extends Panel
class_name Loadout

@onready var title = $Title

@export var data: LoadoutData:
	set(v):
		data = v
		if is_node_ready():
			_update_title()
			
func _ready():
	_update_title()
			
func _update_title():
	if data:
		title.text = data.loadout_name
