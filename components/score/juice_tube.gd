extends Control
class_name JuiceTube

@onready var fill = $Fill

@export var max_value: int

@export var value: float = 0:
	set(v):
		value = clampf(v, 0, max_value)
		queue_redraw()
		
var tween: Tween

func add(v: int):
	var new_value = value + v
	set_value_animated(new_value)

func set_value_animated(v: float):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, 'value', v, 0.4).set_trans(Tween.TRANS_SINE)

func _draw():
	var ratio = value / max_value
	var w = size.x
	var h = size.y
	var fill_w = w * ratio
	#tube
	draw_rect(Rect2(0, 0, w, h), Color(0.2, 0.1, 0.1, 0.05))
	#juice
	draw_rect(Rect2(0, 0, fill_w, h), Styles.VIOLET)
	#border
	draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.3), false, 2.0)
