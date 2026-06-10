extends Control
class_name Item

signal clicked(item: Item)
signal played(item: Item)

@onready var name_label = $NameContainer/Name
@onready var description_label = $DescriptionContainer/Description

@export var data: ItemData:
	set(value):
		data = value
		_update_labels()
		
var selected: bool = false:
	set(value):
		selected = value
		_on_selected_changed()

func _ready():
	data.data_changed.connect(_update_labels)
	_update_labels()

func _update_labels():
	if data:
		if name_label:
			name_label.text = data.item_name
		if description_label:
			description_label.text = data.description

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func _on_selected_changed():
	queue_redraw()
	var tween = create_tween()
	var target = Vector2(1.2, 1.2) if selected else Vector2(1, 1)
	tween.tween_property(self, "scale", target, 0.15)
