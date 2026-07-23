extends Control
class_name Board

signal space_clicked(space: Space)
signal space_hovered(space: Space)

var SpaceScene = preload("res://components/space/space.tscn")

@export var max_spaces: int

const BOARD_SIZE = Vector2(800, 800)
const DEFAULT_NUM_STARTING_SPACES = 3
const NUM_EXPANSIONS = 1
const MAX_RADIUS := 3
const SPACING := 100
const SQRT_3_OVER_2 = sqrt(3) / 2.0
const LINK_COLOR = Color(0.75, 0.75, 0.75)
const LINK_WIDTH = 4.0

var num_starting_spaces := DEFAULT_NUM_STARTING_SPACES
var start_space_coord = Vector2i(0, 0)
var start_space_pos: Vector2
var expanding := false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

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
	custom_minimum_size = BOARD_SIZE
	start_space_pos = BOARD_SIZE / 2
	#_add_background()
	
func start():
	_create_all_spaces()
	print("created: ", spaces.keys())
	print("start coord=", start_space_coord, " type=", typeof(start_space_coord), " has key=", spaces.has(start_space_coord))
	_enable_space(spaces[start_space_coord], true)
	grow(num_starting_spaces - 1, true)
	
func get_spaces():
	return spaces
	
func place(token: Token, space: Space):
	space.place_token(token)

func highlight(path: Array):
	for space in path:
		space.token.pulse()
		#space.token.animate_highlight()
	#await get_tree().create_timer(0.5).timeout
	#for space in path:
	#	space.token.animate_default()
	
func _create_all_spaces():
	var target := max_spaces if max_spaces > 0 else _all_coords_within(MAX_RADIUS).size()

	_create_space(start_space_coord)                 # always start at center
	var open := _neighbors_within(start_space_coord) # candidate coords to grow into

	while spaces.size() < target and not open.is_empty():
		var idx := randi() % open.size()
		var coord = open[idx]
		open.remove_at(idx)
		if spaces.has(coord):                         # already created via another neighbor
			continue
		_create_space(coord)
		for n in _neighbors_within(coord):
			if not spaces.has(n):
				open.append(n)

func _neighbors_within(coord: Vector2i) -> Array:
	var result := []
	for offset in DIR_OFFSETS:
		var n = coord + offset
		if _hex_dist_from_center(n) <= MAX_RADIUS:
			result.append(n)
	return result
	
func _all_coords_within(radius: int) -> Array:
	var coords := []
	for q in range(-radius, radius + 1):
		for r in range(-radius, radius + 1):
			var coord = Vector2i(q, r)
			if _hex_dist_from_center(coord) <= radius:
				coords.append(coord)
	return coords
		
func _draw():
	var drawn := {}
	for space in spaces.values():
		if not space.enabled:
			continue
		for dir in range(6):
			var neighbor = space.links[dir]
			if neighbor == null:
				continue
			var key = _edge_key(space, neighbor)
			if drawn.has(key):
				continue
			drawn[key] = true
			draw_line(space.position, neighbor.position, LINK_COLOR, LINK_WIDTH)
	
func _hex_dist_from_center(coord: Vector2i) -> int:
	return max(abs(coord.x), abs(coord.y), abs(coord.x + coord.y))
	
func _edge_key(a: Space, b: Space):
	if a.get_instance_id() < b.get_instance_id():
		return str(a.get_instance_id()) + "-" + str(b.get_instance_id())
	return str(b.get_instance_id()) + "-" + str(a.get_instance_id())
	
func _add_background():
	var background = StyleBoxFlat.new()
	background.bg_color = Color.WHITE
	add_theme_stylebox_override("panel", background)
	
func _coord_to_pixel(coord: Vector2i):
	var x = SPACING * SQRT_3_OVER_2	* (coord.x * 2 + coord.y) + start_space_pos.x
	var y = SPACING * 1.5 * coord.y + start_space_pos.y
	return Vector2(x, y)
	
func _enable_space(space: Space, is_starting_space := false) -> void:
	space.enabled = true
	space.pop_open()
	if not is_starting_space and space.has_enhancement():
		Sound.play(Sound.SOUND_ENHANCED_SPACE)
	
func _create_space(coord: Vector2i) -> Space:
	var space = SpaceFactory.create_random_scene()
	space.coord = coord
	space.position = _coord_to_pixel(coord)
	space.enabled = false                      # created disabled
	add_child(space)
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
	queue_redraw()
	
func _connect_spaces(a: Space, dir: int, b: Space):
	a.links[dir] = b
	b.links[(dir + 3) % 6] = a
	queue_redraw()
	
func _on_space_clicked(space: Space):
	space_clicked.emit(space)
	
func _on_space_hovered(space: Space):
	space_hovered.emit(space)

func grow(expansions: int, is_starting_space := false):
	var grown := 0
	while grown < expansions:
		var frontier := spaces.values().filter(func(s):
			return s.enabled and _has_disabled_neighbor(s))
		if frontier.is_empty():
			return
		var space = frontier[randi() % frontier.size()]
		_enable_one_neighbor(space, is_starting_space)
		grown += 1
			
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
	var dir = dirs[randi() % dirs.size()]
	_enable_space(space.links[dir], is_starting_space)
