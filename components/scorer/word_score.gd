extends MarginContainer
class_name WordScore

@onready var label = $Score

@export var score := 0:
	set(v):
		score = v
		_update_score()
		
func _ready():
	_update_score(false)
	pivot_offset = size / 2

func add(value: int):
	score += value
	
func clear():
	score = 0
	
func _update_score(shake := true):
	if label:
		label.text = str(score) if score > 0 else ''
		if shake:
			_shake()

func _shake():
	var tween = create_tween()
	var start_rotation = rotation
	tween.tween_property(self, 'rotation', start_rotation + deg_to_rad(3), 0.05)
	tween.tween_property(self, 'rotation', start_rotation - deg_to_rad(3), 0.05)
	tween.tween_property(self, 'rotation', start_rotation, 0.03)
	
