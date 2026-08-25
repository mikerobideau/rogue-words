class_name Relic
extends Control

@onready var name_label = $NameContainer/Name

@export var data: RelicData:
	set(value):
		data = value
		_update_label()
		_refresh_disabled()

func set_disabled(v: bool) -> void:
	if data:
		data.disabled = v
	_refresh_disabled()

func _refresh_disabled() -> void:
	modulate = Color(0.45, 0.45, 0.45, 0.7) if (data and data.disabled) else Color.WHITE

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
	ScorePopup.show(ScorePopup.Template.DEFAULT, '+' + str(v), self)

func pulse(delay := Settings.BEAT):
	var tween = create_tween()
	var original = rotation
	var d = delay / 5
	tween.tween_property(self, 'rotation', deg_to_rad(5), d)
	tween.tween_property(self, 'rotation', deg_to_rad(-5), d)
	tween.tween_property(self, 'rotation', deg_to_rad(3), d)
	tween.tween_property(self, 'rotation', deg_to_rad(-3), d)
	tween.tween_property(self, 'rotation', original, d)
