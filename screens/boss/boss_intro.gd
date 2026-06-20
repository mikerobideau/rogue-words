extends Control
class_name BossIntro

@onready var title_label = $Body/VBoxContainer/Title
@onready var description_label = $Body/VBoxContainer/Description

var title := '':
	set(v):
		title = v
		if title_label:
			title_label.text = v
		
var description := '':
	set(v):
		description = v
		if description_label:
			description_label.text = v

func _ready():
	title_label.modulate.a = 0.0
	description_label.modulate.a = 0.0
	title_label.text = title
	description_label.text = description
	await get_tree().create_timer(0.5).timeout
	_animate()
	
func _animate():
	var tween = create_tween()
	tween.tween_property(title_label, 'modulate:a', 1, 0.5)
	tween.tween_property(description_label, 'modulate:a', 1, 0.5).set_delay(0.5)
