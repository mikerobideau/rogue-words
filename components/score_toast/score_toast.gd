extends Control
class_name ScoreToast

@export var text: String

@onready var label = $Label
@onready var background = $Background

func _ready() -> void:
	label.text = text
	label.size = label.get_minimum_size()
	background.size = label.size + Vector2(20, 0)
	background.position = -background.size / 2
	label.position = -label.size / 2
	#pivot_offset = size / 2
	
func animate():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, 'position:y', position.y + 20, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'modulate:a', 0.0, 0.5).set_delay(0.3)
	await tween.finished
	queue_free()
