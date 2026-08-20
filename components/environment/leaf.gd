extends Sprite2D
class_name Leaf

@export var fall_speed := 120.0
@export var sway_amplitude := 40.0
@export var sway_speed := 2.0
@export var spin_speed := 1.5
@export var despawn_y := 1600.0

var base_x := 0.0
var t := 0.0

func _ready() -> void:
	base_x = position.x

func _process(delta: float) -> void:
	t += delta
	position.y += fall_speed * delta
	position.x = base_x + sin(t * sway_speed) * sway_amplitude
	rotation += spin_speed * delta
	if position.y > despawn_y:
		queue_free()
