extends Control
class_name JuiceTube

@onready var fill = $Fill

@export var max_value: int:
	set(v):
		max_value = v
		_update_progress()

@export var value: float = 0:
	set(v):
		value = clampf(v, 0, max_value)
		_update_progress()
		
var progress := 0.0
var progress_for_animation := 0.0
var fill_tween: Tween
var color_tween: Tween
var is_full := false

func _ready():
	fill.material = fill.material.duplicate()
	fill.material.set_shader_parameter('progress', progress)

func _update_progress():
	if !max_value:
		return
	progress = clampf(value / max_value, 0, 1)
	progress_for_animation = clampf(progress, 0, 0.99) #ensures top of wave is visible at complete fill
	if progress > 0 and !is_full:
		Sound.play(Sound.SOUND_JUICE)
	if value >= max_value:
		is_full = true
	_animate_progress()
	if progress >= 1:
		_style_complete()

func _animate_progress():
	if fill_tween:
		fill_tween.kill()
	fill_tween = create_tween()
	fill_tween.tween_property(fill, 'material:shader_parameter/progress', progress_for_animation, 0.4).set_trans(Tween.TRANS_SINE)

func _style_complete():
	if color_tween:
		color_tween.kill()
	color_tween = create_tween()
	color_tween.parallel().tween_property(fill, 'material:shader_parameter/wave_1_color', Color.DARK_MAGENTA, 0.4).set_trans(Tween.TRANS_SINE)
	color_tween.parallel().tween_property(fill, 'material:shader_parameter/wave_2_color', Color.MAGENTA, 0.4).set_trans(Tween.TRANS_SINE)
