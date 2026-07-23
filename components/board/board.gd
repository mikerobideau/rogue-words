extends Control
class_name Board

signal space_clicked(space: Space)
signal space_hovered(space: Space)

const DEFAULT_NUM_STARTING_SPACES = 3
const NUM_EXPANSIONS = 1
const MAX_RADIUS := 3
const MAX_EDGES := 5
const SPACING := 80
const SQRT_3_OVER_2 = sqrt(3) / 2.0
const CENTER_BIAS_SAMPLES := 1   # 1 = pure random shape, higher = rounder/tighter

@onready var space_container: SpaceContainer = $SpaceContainer

var num_starting_spaces := DEFAULT_NUM_STARTING_SPACES
var start_space_coord := Vector2i(0, 0)
var start_space_pos: Vector2
var max_spaces := 0              # set by Round; 0 = unbounded

var spaces: Dictionary = {}

const DIR_OFFSETS := [
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
]

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_recenter)

func start():
	_create_all_spaces()
	space_container.center_in(size)
	_enable_space(spaces[start_space_coord], true)
	grow(num_starting_spaces - 1, true)

func _recenter() -> void:
	if space_container.has_spaces:
		space_container.center_in(size)

func get_spaces():
	return spaces

func place(token: Token, space: Space):
	space.place_token(token)

func highlight(path: Array):
	for space in path:
		space.token.pulse()

#--- creation: randomized connected blob, unique each round ---

func _create_all_spaces():
	var target := max_spaces if max_spaces > 0 else _disk_size(MAX_RADIUS)

	_create_space(start_space_coord)
	var open := _neighbors_within(start_space_coord)

	while spaces.size() < target and not open.is_empty():
		var idx := _pick_index(open)
		var coord = open[idx]
		open.remove_at(idx)
		if spaces.has(coord):
			continue
		if not _can_create(coord):
			continue
		_create_space(coord)
		for n in _neighbors_within(coord):
			if not spaces.has(n):
				open.append(n)

# best-of-N sampling, biased toward center so blobs stay compact
func _pick_index(open: Array) -> int:
	var best := 0
	var best_dist := 9999
	for i in mini(CENTER_BIAS_SAMPLES, open.size()):
		var idx := randi() % open.size()
		var d := _hex_dist_from_center(open[idx])
		if d < best_dist:
			best_dist = d
			best = idx
	return best

func _neighbors_within(coord: Vector2i) -> Array:
	var result := []
	for offset in DIR_OFFSETS:
		var n = coord + offset
		if _hex_dist_from_center(n) <= MAX_RADIUS:
			result.append(n)
	return result

func _disk_size(radius: int) -> int:
	return 1 + 3 * radius * (radius + 1)

# number of already-created spaces adjacent to a coord
func _created_neighbor_count(coord: Vector2i) -> int:
	var count := 0
	for offset in DIR_OFFSETS:
		if spaces.has(coord + offset):
			count += 1
	return count

# a coord may be created only if neither it nor any existing
# neighbor would end up touching more than MAX_EDGES spaces
func _can_create(coord: Vector2i) -> bool:
	if _created_neighbor_count(coord) > MAX_EDGES:
		return false
	for offset in DIR_OFFSETS:
		var m = coord + offset
		if spaces.has(m) and _created_neighbor_count(m) >= MAX_EDGES:
			return false
	return true

func _create_space(coord: Vector2i) -> Space:
	var space = SpaceFactory.create_random_scene()
	space.coord = coord
	space.position = _coord_to_pixel(coord)
	space.enabled = false
	space_container.add_space(space)
	space.clicked.connect(_on_space_clicked)
	space.hovered.connect(_on_space_hovered)
	spaces[coord] = space
	_link_neighbors(space)
	return space

func _link_neighbors(space: Space):
	for dir in range(6):
		var neighbor_coord = space.coord + DIR_OFFSETS[dir]
		var neighbor = spaces.get(neighbor_coord)
		if neighbor != null:
			space.links[dir] = neighbor
			neighbor.links[(dir + 3) % 6] = space
	space_container.queue_redraw()

#--- growth: enable existing disabled spaces ---

func _enable_space(space: Space, is_starting_space := false) -> void:
	space.enabled = true
	space.pop_open()
	space_container.queue_redraw()
	if not is_starting_space and space.has_enhancement():
		Sound.play(Sound.SOUND_ENHANCED_SPACE)

func grow(expansions: int, is_starting_space := false):
	var grown := 0
	while grown < expansions:
		if max_spaces > 0 and _enabled_count() >= max_spaces:
			return
		var frontier := spaces.values().filter(func(s):
			return s.enabled and _has_disabled_neighbor(s))
		if frontier.is_empty():
			return
		var space = frontier[randi() % frontier.size()]
		_enable_one_neighbor(space, is_starting_space)
		grown += 1

func _enabled_count() -> int:
	return spaces.values().filter(func(s): return s.enabled).size()

func _has_disabled_neighbor(space: Space) -> bool:
	for dir in range(6):
		var n = space.links[dir]
		if n != null and not n.enabled:
			return true
	return false

func _enable_one_neighbor(space: Space, is_starting_space := false) -> void:
	var dirs := []
	for dir in range(6):
		var n = space.links[dir]
		if n != null and not n.enabled:
			dirs.append(dir)
	if dirs.is_empty():
		return
	var dir = dirs[randi() % dirs.size()]
	_enable_space(space.links[dir], is_starting_space)

#--- geometry ---

func _hex_dist_from_center(coord: Vector2i) -> int:
	return max(abs(coord.x), abs(coord.y), abs(coord.x + coord.y))

func _coord_to_pixel(coord: Vector2i) -> Vector2:
	var x = SPACING * SQRT_3_OVER_2 * (coord.x * 2 + coord.y) + start_space_pos.x
	var y = SPACING * 1.5 * coord.y + start_space_pos.y
	return Vector2(x, y)

func _on_space_clicked(space: Space):
	space_clicked.emit(space)

func _on_space_hovered(space: Space):
	space_hovered.emit(space)
