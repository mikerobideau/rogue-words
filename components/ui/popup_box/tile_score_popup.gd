extends HBoxContainer
class_name TileScorePopup

const SCALE_MIN = Vector2(1.35, 1.35)

@onready var base_label: Label = $Base
@onready var x_label: Label = $X
@onready var mult_label: Label = $Mult

var base_tween: Tween
var mult_tween: Tween
var base := 0
var mult := 1

func set_base(v: int) -> void:
	var increased := v > base
	base = v
	base_label.text = str(v)
	if increased:
		_pulse(base_label, 'base')

func set_mult(v: int) -> void:
	var increased := v > mult
	mult = v
	mult_label.text = str(v)
	if increased:
		_pulse(mult_label, 'mult')

func _pulse(node: Control, which: String) -> void:
	node.pivot_offset = node.size / 2
	var t := create_tween()
	if which == 'base':
		if base_tween: base_tween.kill()
		base_tween = t
	else:
		if mult_tween: mult_tween.kill()
		mult_tween = t
	t.tween_property(node, 'scale', SCALE_MIN, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, 'scale', Vector2.ONE, 0.1)
