class_name Relic
extends Control

@onready var name_label = $NameContainer/Name

@export var data: RelicData:
	set(value):
		data = value
		_update_label()
		
func _ready():
	pivot_offset = size / 2
	if data:
		data.data_changed.connect(_update_label)
		data.scaled.connect(_on_data_scaled)
	_update_label()

func _update_label():
	if data:
		if name_label:
			name_label.text = data.relic_name
				
func _on_data_scaled(v: int):
	ScorePopup.show('+' + str(v), self)

func pulse(delay := Settings.SCORE_DELAY_NORMAL):
	var tween = create_tween()
	var original = rotation
	var d = delay / 5
	tween.tween_property(self, 'rotation', deg_to_rad(5), d)
	tween.tween_property(self, 'rotation', deg_to_rad(-5), d)
	tween.tween_property(self, 'rotation', deg_to_rad(3), d)
	tween.tween_property(self, 'rotation', deg_to_rad(-3), d)
	tween.tween_property(self, 'rotation', original, d)
