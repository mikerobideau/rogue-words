extends Control
class_name Pack

@onready var type_label = $TypeLabel
@onready var size_and_choices_label = $Footer/SizeAndChoicesLabel

var data: PackData:
	set(v):
		data = v
		_update_labels()
		
func _ready():
	_update_labels()
	
func _update_labels():
	if type_label:
		type_label.text = data.pack_name
		size_and_choices_label.text = 'Choose ' + str(data.num_picks) + ' of ' + str(data.size)
