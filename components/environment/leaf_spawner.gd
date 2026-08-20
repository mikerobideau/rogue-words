extends Node2D
class_name LeafSpawner

@export var texture: Texture2D
@export var tint := Color(1, 1, 1, 1)
@export var spawn_interval := 1.5
@export var min_scale := 0.4
@export var max_scale := 0.9
@export var min_fall_speed := 80.0
@export var max_fall_speed := 160.0
@export var sway_amplitude := 40.0
@export var sway_speed := 2.0
@export var min_x := -200.0
@export var max_x := 2200.0
@export var spawn_y := -100.0
@export var despawn_y := 1600.0
@export var initial_count := 6

func _ready() -> void:
	modulate = tint
	for i in initial_count:
		_spawn(randf_range(spawn_y, despawn_y))
	_run()

func _run() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		_spawn(spawn_y)

func _spawn(y: float) -> void:
	var leaf := Leaf.new()
	leaf.texture = texture
	var s := randf_range(min_scale, max_scale)
	leaf.scale = Vector2(s, s)
	leaf.position = Vector2(randf_range(min_x, max_x), y)
	leaf.rotation = randf() * TAU
	leaf.fall_speed = randf_range(min_fall_speed, max_fall_speed)
	leaf.sway_amplitude = sway_amplitude * randf_range(0.6, 1.2)
	leaf.sway_speed = sway_speed * randf_range(0.7, 1.3)
	leaf.spin_speed = randf_range(-2.0, 2.0)
	leaf.despawn_y = despawn_y
	add_child(leaf)
