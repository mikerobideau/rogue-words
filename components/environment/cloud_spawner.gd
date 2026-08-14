extends Node2D
class_name CloudSpawner

const TEXTURES := [
	preload("res://assets/sprites/cloud/1x/cloud1.png"),
	preload("res://assets/sprites/cloud/1x/cloud2.png"),
	preload("res://assets/sprites/cloud/1x/cloud3.png"),
]

@export var tint: Color
@export var spawn_interval := 5.0
@export var min_scale := 0.1
@export var max_scale := 0.1
@export var speed := 50.0
@export var spawn_x := -400.0
@export var despawn_x := 3000.0
@export var min_y := 0.0
@export var max_y := 1440
@export var initial_count := 1

func _ready() -> void:
	modulate = tint
	for i in initial_count:
		_spawn(randf_range(spawn_x, despawn_x))
	_run()

func _run() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		_spawn(spawn_x)

func _spawn(x: float) -> void:
	var cloud := Cloud.new()
	cloud.texture = TEXTURES[randi() % TEXTURES.size()]
	var s := randf_range(min_scale, max_scale)
	cloud.scale = Vector2(s, s)
	cloud.position = Vector2(x, randf_range(min_y, max_y))
	cloud.speed = speed
	cloud.despawn_x = despawn_x
	add_child(cloud)
