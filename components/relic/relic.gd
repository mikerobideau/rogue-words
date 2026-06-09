class_name Relic
extends Control

@onready var name_label = $NameContainer/Name
@onready var description_label = $DescriptionContainer/Description
@onready var bonus_label = $Bonus
@onready var count_label = $Count

@export var data: RelicData:
	set(value):
		data = value
		_update_labels()
		
func _ready():
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

func pulse():
	var tween = create_tween()
	tween.tween_property(self, 'scale', Vector2(1.2, 1.2), 0.15)
	tween.tween_property(self, 'scale', Vector2(1, 1), 0.15)
