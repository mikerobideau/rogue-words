extends Node2D
class_name Badge

@onready var label = $Label

const RADIUS = 24.0

var text: String:
	set(v):
		text = v
		label.text = v

var color: Color = Color.WHITE:
	set(v):
		color = v
		queue_redraw()
		
func _draw():
	draw_circle(Vector2.ZERO, RADIUS, color)
