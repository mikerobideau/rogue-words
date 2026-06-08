class_name Relic
extends Control

@onready var name_label = $NameContainer/Name
@onready var description_label = $DescriptionContainer/Description

@export var data: RelicData:
	set(value):
		data = value
		_update_labels()
		
func _ready():
	_update_labels()

func _update_labels():
	if data:
		if name_label:
			name_label.text = data.relic_name
		if description_label:
			description_label.text = data.description

func pulse():
	var tween = create_tween()
	tween.tween_property(self, 'scale', Vector2(1.2, 1.2), 0.15)
	tween.tween_property(self, 'scale', Vector2(1, 1), 0.15)
