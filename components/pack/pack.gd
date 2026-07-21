extends Control
class_name Pack

@onready var body = $Body
@onready var sprite = $Body/Sprite2D
@onready var type_label = $Body/TypeLabel
@onready var footer = $Body/Footer
@onready var size_and_choices_label = $Body/Footer/SizeAndChoicesLabel
@onready var vortex = $Vortex
@onready var flash = $Flash
@onready var burst = $Burst

@export var data: PackData:
	set(v):
		data = v
		_update_labels()
		
func _ready():
	if vortex:
		vortex.position = size / 2
	if burst:
		burst.position = size / 2
	pivot_offset = size / 2
	_update_labels()
	
func _update_labels():
	if type_label:
		type_label.text = data.pack_name
		size_and_choices_label.text = 'Choose ' + str(data.num_picks) + ' of ' + str(data.size)

func animate_open():
	await get_tree().create_timer(0.4).timeout
	
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
	
	#Scale
	#var scale := create_tween().set_parallel(true)
	#scale.tween_property(self, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#await scale.finished
	
	#var squash := create_tween()
	#squash.tween_property(self, "scale", Vector2(1.12, 0.88), 0.12)
	#await squash.finished
	
	#Burst
	#var burst := create_tween().set_parallel(true)
	#burst.tween_property(self, "scale", Vector2(1.35, 1.35), 0.18) \
	#	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#burst.tween_property(body, "modulate:a", 0.0, 0.5)
	#burst.tween_callback(_burst)
	#await burst.finished
	
	#_burst()
	
	#dissolve
	Sound.play(Sound.SOUND_PACK_OPEN)
	var dissolve_tween = create_tween().set_parallel(true)
	var type_label_dissolve_tween = create_tween()
	var size_and_choice_label_dissolve_tween = create_tween()
	
	dissolve_tween.tween_property(sprite.material, 'shader_parameter/dissolve_value', 0, 0.5)
	type_label_dissolve_tween.tween_property(type_label.material, 'shader_parameter/dissolve_value', 0, 0.5)
	size_and_choice_label_dissolve_tween.tween_property(footer.material, 'shader_parameter/dissolve_value', 0, 0.5)
	await dissolve_tween.finished
	
func _burst() -> void:
	#flash.modulate.a = 0.9
	#create_tween().tween_property(flash, "modulate:a", 0.0, 0.25)
	burst.restart()
