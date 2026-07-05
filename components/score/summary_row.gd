extends MarginContainer
class_name Summary_Row

@onready var header_label = $VBoxContainer/Header
@onready var value_label = $VBoxContainer/Value

@export var header: String:
	set(v):
		header = v
		if header_label:
			header_label.text = str(v)
		
@export var value: String:
	set(v):
		value = v
		if value_label:
			value_label.text = v
			
func _ready():
	header_label.text = header
	value_label.text = value
