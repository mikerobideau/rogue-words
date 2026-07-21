extends Control
class_name Pack

@onready var body = $Body
@onready var sprite = $Body/Sprite2D
@onready var footer = $Body/Footer
@onready var size_and_choices_label = $Body/Footer/SizeAndChoicesLabel

@export var data: PackData:
	set(v):
		data = v
		_update_labels()
		
func _ready():
	sprite.texture = data.texture
	pivot_offset = size / 2
	_update_labels()
	
func _update_labels():
	if is_node_ready():
		size_and_choices_label.text = 'Choose ' + str(data.num_picks) + ' of ' + str(data.size)

func animate_open():
	await get_tree().create_timer(0.2).timeout
	Sound.play(Sound.SOUND_PACK_OPEN)
	
	var angles = [2, -1, 0]

	var t := create_tween()
	var steps := 12
	var base_angle := 0.8     # starting wobble in degrees
	var growth := 1.28        # amplitude multiplier per step (>1 = ramps up)
	var base_dur := 0.07      # starting step duration
	var speedup := 0.88       # duration multiplier per step (<1 = speeds up)

	for i in steps:
		var angle := base_angle * pow(growth, i)     # exponential amplitude
		var dur := base_dur * pow(speedup, i)        # exponential speed-up
		var dir := 1.0 if i % 2 == 0 else -1.0       # alternate sides
		t.tween_property(self, "rotation", deg_to_rad(angle * dir), dur)

	t.tween_property(self, "rotation", 0.0, 0.05)    # settle to center

	await t.finished
	
	#dissolve
	var dissolve_tween = create_tween().set_parallel(true)
	var type_label_dissolve_tween = create_tween()
	var size_and_choice_label_dissolve_tween = create_tween()
	
	dissolve_tween.tween_property(sprite.material, 'shader_parameter/burst_progress', 1, 0.5)
	size_and_choice_label_dissolve_tween.tween_property(footer.material, 'shader_parameter/dissolve_value', 0, 0.5)
	await dissolve_tween.finished
