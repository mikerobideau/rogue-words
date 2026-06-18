extends Control
class_name Plunger

@onready var panel = $Panel
@onready var label = $Label

const PLUNGER_DEFAULT_WIDTH = 100
const PLUNGER_COLOR = Color.SEA_GREEN

var tween: Tween
var shake_tween: Tween

@export var score := 0:
	set(v):
		score = v
		if label:
			label.text = str(score) if score > 0 else ''
			
var plunger_width: float = 0.0:
	set(v):
		plunger_width = v
		queue_redraw()
		if label:
			label.position.x = size.x - plunger_width
	
func _ready():
	plunger_width = PLUNGER_DEFAULT_WIDTH
	
func _draw():
	draw_rect(
		Rect2(size.x -plunger_width, 0, plunger_width, size.y),
		PLUNGER_COLOR
	)
	
func plunge_in():
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, 'plunger_width', size.x, 0.2)
	tween.tween_interval(0.15)
	await tween.finished
	
func plunge_out():
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, 'plunger_width', PLUNGER_DEFAULT_WIDTH, 0.2)
	await tween.finished
	
func shake_score():
	return
	var tween = create_tween()
	label.rotation = 0
	tween.tween_property(label, 'scale', Vector2(1.2, 1.2), 0.03)
	tween.tween_property(label, 'rotation', deg_to_rad(3), 0.05)
	tween.tween_property(label, 'rotation', deg_to_rad(3), 0.05)
	tween.tween_property(label, 'rotation', 0.0, 0.03)
	tween.tween_property(label, 'scale', Vector2(1.0, 1.0), 0.06)
		
