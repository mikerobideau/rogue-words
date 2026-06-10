extends Node2D
class_name ScoreToast

@export var text: String

@onready var label = $Label
@onready var background = $Background

func _ready() -> void:
	label.text = text
	position = Vector2(get_viewport_rect().size.x / 2, 100)
	label.size = label.get_minimum_size()
	background.size = label.size + Vector2(20, 0)
	background.position = -background.size / 2
	label.position = -label.size / 2
	await get_tree().create_timer(0.5).timeout
	queue_free()
