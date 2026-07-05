extends Sprite2D
class_name Item

signal played(item: Item)
var scale_tween: Tween
var position_tween: Tween

@onready var name_label = $NameContainer/Name
@onready var description_label = $DescriptionContainer/Description

@export var float_duration: float = 0.3
@export var arc_height: float = 120.0

@export var data: ItemData:
	set(value):
		data = value
		_on_data_changed()
		
func _ready():
	_on_data_changed()
		
func _on_data_changed():
	if data:
		name = data.item_name
		texture = data.icon

func animate_selected(selected: bool):
	if scale_tween:
		scale_tween.kill()
	var scale_tween = create_tween()
	var target = Vector2(1.1, 1.1) if selected else Vector2(1, 1)
	scale_tween.tween_property(self, "scale", target, 0.15)
	
func float_to_target(target_global_pos: Vector2) -> void:
	if position_tween:
		position_tween.kill()
	if scale_tween:
		scale_tween.kill()

	var start_pos: Vector2 = global_position
	var original_parent := get_parent()
	assert(original_parent != null, "Item has no parent — was it added to the tree before float_to_target()?")

	var tree_root := get_tree().root

	original_parent.remove_child(self)
	tree_root.add_child(self)
	global_position = start_pos

	var control_pos: Vector2 = start_pos.lerp(target_global_pos, 0.5) - Vector2(0, arc_height)

	position_tween = create_tween()
	position_tween.tween_method(
		func(t: float): global_position = _quadratic_bezier(start_pos, control_pos, target_global_pos, t),
		0.0, 1.0, float_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var base_scale := scale
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", base_scale * 1.25, float_duration * 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", base_scale * 0.85, float_duration * 0.35) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	scale_tween.tween_property(self, "scale", base_scale, float_duration * 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await position_tween.finished
	played.emit(self)
	await _animate_consumed()

func _animate_consumed() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.12) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var a := p0.lerp(p1, t)
	var b := p1.lerp(p2, t)
	return a.lerp(b, t)
