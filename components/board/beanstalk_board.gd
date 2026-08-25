extends Control
class_name BeanstalkBoard

signal space_clicked(space: Space)
signal space_hovered(space: Space)

const DEFAULT_NUM_STARTING_SPACES = 1
const NUM_EXPANSIONS = 1
const SPACING := 90
const SQRT_3_OVER_2 = sqrt(3) / 2.0

const MAX_ROWS := 7
const MAX_COLS := 7

const SHAPE_SLACK := 1

const EMPTY_ALPHA := 0.55

const DIR_OFFSETS := [
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
]

@onready var space_container: SpaceContainer = $SpaceContainer

var num_starting_spaces := DEFAULT_NUM_STARTING_SPACES
var start_space_coord := Vector2i(0, 0)
var start_space_pos: Vector2
var max_spaces := 0
var turns_per_round := 0
var leaves_per_round := 0

var spaces: Dictionary = {}

var _placed_count := 0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_center_board)

func start():
	for coord in _generate_shape(_total_spaces()):
		_create_space(coord)
	var seed_space: Space = spaces[start_space_coord]
	seed_space.place_token(TokenFactory.create_leaf())
	_grow_links(seed_space)
	_plant_leaves(leaves_per_round)
	_update_opacity()
	_center_board()

func get_spaces():
	return spaces

func place(token: Token, space: Space):
	space.place_token(token)
	_placed_count += 1
	if space.has_enhancement():
		Sound.play(Sound.SOUND_ENHANCED_SPACE)
	_grow_links(space)
	_update_opacity()

func highlight(path: Array):
	for space in path:
		space.token.pulse()

#--- growth ---

func _plant_leaves(count: int) -> void:
	var options := _empty_spaces()
	options.shuffle()
	var placed := 0
	for leaf_space in options:
		if placed >= count:
			break
		if _adjacent_to_leaf(leaf_space.coord):
			continue
		leaf_space.place_token(TokenFactory.create_leaf())
		_grow_links(leaf_space)
		placed += 1

func _adjacent_to_leaf(coord: Vector2i) -> bool:
	for offset in DIR_OFFSETS:
		var neighbor: Space = spaces.get(coord + offset)
		if neighbor != null and neighbor.token != null:
			return true
	return false

func _update_opacity() -> void:
	for space in spaces.values():
		space.modulate.a = 1.0 if space.token != null else EMPTY_ALPHA

func _empty_spaces() -> Array:
	var result := []
	for space in spaces.values():
		if space.token == null:
			result.append(space)
	return result

#--- creation ---

func _total_spaces() -> int:
	return num_starting_spaces + turns_per_round + leaves_per_round

func _generate_shape(count: int) -> Array:
	var shape := { start_space_coord: true }
	while shape.size() < count:
		var frontier := _frontier(shape)
		if frontier.is_empty():
			break
		var min_shared := 7
		for c in frontier:
			min_shared = mini(min_shared, _shared_count(c, shape))
		var candidates := frontier.filter(func(c): return _shared_count(c, shape) <= min_shared + SHAPE_SLACK)
		shape[candidates.pick_random()] = true
	return shape.keys()

func _frontier(shape: Dictionary) -> Array:
	var seen := {}
	var result := []
	for coord in shape:
		for offset in DIR_OFFSETS:
			var c: Vector2i = coord + offset
			if shape.has(c) or seen.has(c) or not _within_bounds(c):
				continue
			seen[c] = true
			result.append(c)
	return result

func _shared_count(coord: Vector2i, shape: Dictionary) -> int:
	var n := 0
	for offset in DIR_OFFSETS:
		if shape.has(coord + offset):
			n += 1
	return n

func _within_bounds(coord: Vector2i) -> bool:
	if absi(coord.y - start_space_coord.y) > (MAX_ROWS - 1) / 2:
		return false
	if absi(_col(coord) - _col(start_space_coord)) > MAX_COLS - 1:
		return false
	return true

func _create_space(coord: Vector2i) -> Space:
	var space = SpaceFactory.create_random_scene()
	space.coord = coord
	space.position = _coord_to_pixel(coord)
	space_container.add_space(space)
	space.clicked.connect(_on_space_clicked)
	space.hovered.connect(_on_space_hovered)
	space.modulate.a = EMPTY_ALPHA
	spaces[coord] = space
	_link_neighbors(space)
	space.pop_open()
	return space

func _grow_links(space: Space) -> void:
	for dir in range(6):
		var neighbor = space.links[dir]
		if neighbor != null and neighbor.token != null:
			space_container.add_link(space, neighbor)

func _link_neighbors(space: Space):
	for dir in range(6):
		var neighbor_coord = space.coord + DIR_OFFSETS[dir]
		var neighbor = spaces.get(neighbor_coord)
		if neighbor != null and neighbor != space:
			space.links[dir] = neighbor
			neighbor.links[(dir + 3) % 6] = space

#--- geometry ---

func _center_board() -> void:
	if not space_container.has_spaces:
		return
	space_container.position = size / 2.0 - _coord_to_pixel(start_space_coord)

func _col(coord: Vector2i) -> int:
	return coord.x * 2 + coord.y

func _coord_to_pixel(coord: Vector2i) -> Vector2:
	var x = SPACING * SQRT_3_OVER_2 * (coord.x * 2 + coord.y) + start_space_pos.x
	var y = SPACING * 1.5 * coord.y + start_space_pos.y
	return Vector2(x, y)

func _on_space_clicked(space: Space):
	if space.token == null:
		var full := max_spaces > 0 and _placed_count >= max_spaces
		if full:
			return
	space_clicked.emit(space)

func _on_space_hovered(space: Space):
	space_hovered.emit(space)
