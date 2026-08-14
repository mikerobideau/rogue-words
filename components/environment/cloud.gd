extends Sprite2D
class_name Cloud

@export var speed := 30.0
@export var despawn_x := 3000.0

func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x > despawn_x:
		queue_free()
