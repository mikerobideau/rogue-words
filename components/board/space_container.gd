extends Node2D
class_name SpaceContainer

const LINK_COLOR = Color.SADDLE_BROWN
const LINK_COLOR_DISABLED = Color(0.75, 0.75, 0.75)
const LINK_WIDTH = 4.0

# Art for the vine segment between two spaces. Every link on a hex grid is the
# same length -- SPACING * sqrt(3), about 156px at SPACING 90 -- so a single
# texture covers all six directions and is simply rotated onto each edge.
# Author it horizontally, that length wide. Leave unset to keep drawing plain
# lines.
@export var link_texture: Texture2D
# 0 uses the texture's own height
@export var link_thickness := 0.0

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
			_draw_link(space.position, neighbor.position,
				space.enabled and neighbor.enabled)

func _draw_link(from: Vector2, to: Vector2, active: bool) -> void:
	if link_texture == null:
		draw_line(from, to, LINK_COLOR if active else LINK_COLOR_DISABLED, LINK_WIDTH)
		return
	# each edge is drawn once, from whichever endpoint we reached first -- pin
	# the direction so an asymmetric texture never renders flipped
	if to.x < from.x or (to.x == from.x and to.y < from.y):
		var swap := from
		from = to
		to = swap
	var delta := to - from
	var thickness := link_thickness if link_thickness > 0.0 else float(link_texture.get_height())
	var tint := Color.WHITE if active else LINK_COLOR_DISABLED
	# rotate the canvas onto the edge, then draw the segment centred on it
	draw_set_transform((from + to) / 2.0, delta.angle(), Vector2.ONE)
	draw_texture_rect(
		link_texture,
		Rect2(-delta.length() / 2.0, -thickness / 2.0, delta.length(), thickness),
		false,
		tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _edge_key(a: Space, b: Space) -> String:
	if a.get_instance_id() < b.get_instance_id():
		return str(a.get_instance_id()) + "-" + str(b.get_instance_id())
	return str(b.get_instance_id()) + "-" + str(a.get_instance_id())
