extends Node2D
class_name Link

@onready var vine: Sprite2D = $Vine
@onready var leaf1: Sprite2D = $Leaf1
@onready var leaf2: Sprite2D = $Leaf2
@onready var leaf3: Sprite2D = $Leaf3

const VINE_GROW_SECONDS = 0.5
const LEAF_GROW_SECONDS = 0.5

func set_endpoints(from: Vector2, to: Vector2) -> void:
	position = (from + to) / 2.0
	rotation = (to - from).angle()

func grow() -> void:
	var leaf = [leaf1, leaf2, leaf3].pick_random()
	vine.material.set_shader_parameter("progress", 0.0)
	leaf.material.set_shader_parameter("progress", 0.0)
	leaf.visible = true
	var t := create_tween()
	t.tween_method(func(v): vine.material.set_shader_parameter("progress", v),
		0.0, 1.0, VINE_GROW_SECONDS).set_ease(Tween.EASE_OUT)
	t.tween_method(func(v): leaf.material.set_shader_parameter("progress", v),
		0.0, 1.0, LEAF_GROW_SECONDS).set_ease(Tween.EASE_OUT)
