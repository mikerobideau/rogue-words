extends Node2D
class_name SpaceContainer

const LINK_COLOR = Color.SADDLE_BROWN
const LINK_COLOR_DISABLED = Color(0.75, 0.75, 0.75)
const LINK_WIDTH = 4.0

var bounds := Rect2()
var has_spaces := false

func add_space(space: Space) -> void:
	add_child(space)
	if not has_spaces:
		bounds = Rect2(space.position, Vector2.ZERO)
		has_spaces = true
	else:
		bounds = bounds.expand(space.position)

func center_in(rect_size: Vector2) -> void:
	position = rect_size / 2.0 - bounds.get_center()

func _draw() -> void:
	var drawn := {}
	for space in get_children():
		if not space is Space:
			continue
		for dir in range(6):
			var neighbor = space.links[dir]
			if neighbor == null:
				continue
			var key = _edge_key(space, neighbor)
			if drawn.has(key):
				continue
			drawn[key] = true
			var color = LINK_COLOR if (space.enabled and neighbor.enabled) else LINK_COLOR_DISABLED
			draw_line(space.position, neighbor.position, color, LINK_WIDTH)

func _edge_key(a: Space, b: Space) -> String:
	if a.get_instance_id() < b.get_instance_id():
		return str(a.get_instance_id()) + "-" + str(b.get_instance_id())
	return str(b.get_instance_id()) + "-" + str(a.get_instance_id())
