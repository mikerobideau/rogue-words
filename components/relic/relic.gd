class_name Relic
extends Control

@onready var name_label = $NameContainer/Name
@onready var description_label = $DescriptionContainer/Description
@onready var bonus_label = $Footer/HBoxContainer/Bonus
@onready var count_label = $Footer/HBoxContainer/Count
@onready var border = $Border

@export var data: RelicData:
	set(value):
		data = value
		_update_labels()
		
func _ready():
	pivot_offset = size / 2
	border.color = Color.REBECCA_PURPLE
	data.data_changed.connect(_update_labels)
	_update_labels()

func _update_labels():
	if data:
		if name_label:
			name_label.text = data.relic_name
		if description_label:
			description_label.text = data.description
		if bonus_label:
			if data.has_bonus:
				bonus_label.text = 'Bonus: ' + str(data.bonus)
			else:
				bonus_label.visible = false
		if count_label:
			if data.has_count:
				count_label.text = 'Count: ' + str(data.count)	
			else:
				count_label.visible = false	

func pulse(delay := Settings.SCORE_DELAY_NORMAL):
	var tween = create_tween()
	var original = rotation
	var d = delay / 5
	tween.tween_property(self, 'rotation', deg_to_rad(5), d)
	tween.tween_property(self, 'rotation', deg_to_rad(-5), d)
	tween.tween_property(self, 'rotation', deg_to_rad(3), d)
	tween.tween_property(self, 'rotation', deg_to_rad(-3), d)
	tween.tween_property(self, 'rotation', original, d)
