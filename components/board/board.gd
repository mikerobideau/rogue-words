extends Panel
class_name Board

signal space_clicked(space: Space)

var SpaceScene = preload("res://components/space/space.tscn")

const SOUND_ENHANCED_SPACE = 'small_bonus' 
const BOARD_SIZE = Vector2(450, 450)
const NUM_STARTING_SPACES = 5
const NUM_EXPANSIONS = 1
const MAX_RADIUS := 3
const SPACING := 70
const SQRT_3_OVER_2 = sqrt(3) / 2.0
const LINK_COLOR = Color(0.75, 0.75, 0.75)
const LINK_WIDTH = 2.0


var start_space_coord = Vector2(0, 0)
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
	_add_background()
	_create_space(start_space_coord, true)
	grow(NUM_STARTING_SPACES - 1, true)
	
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
		
func _draw():
	var drawn := {}
	for space in spaces.values():
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
	
func _create_space(coord: Vector2i, is_starting_space := false) -> Space:
	var space = SpaceFactory.create_random_scene()
	space.coord = coord
	space.position = _coord_to_pixel(coord)
	add_child(space)
	space.clicked.connect(_on_space_clicked)
	spaces[coord] = space
	_link_neighbors(space)
	if !is_starting_space and space.has_enhancement():
		Sound.play(SOUND_ENHANCED_SPACE)
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
	
func expand_around(space: Space):
	expanding = true
	var num_expansions = 3
	var dirs = [0, 1, 2, 3, 4, 5]
	dirs.shuffle()
	var expansions = 0
	while expansions < 3 and dirs.size() > 0:
		var dir = dirs.pop_back()
		if space.links[dir] != null:
			continue
		var target_coord = space.coord + DIR_OFFSETS[dir]
		var neighbor = spaces.get(target_coord)
		if neighbor == null:
			if _hex_dist_from_center(target_coord) > MAX_RADIUS:
				continue
			neighbor = _create_space(target_coord)
			await get_tree().create_timer(0.15).timeout
			expansions += 1
	expanding = false

func grow(expansions: int, is_starting_space := false):
	var growable = spaces.values().filter(func(s): return s.links.has(null))
	if growable.is_empty():
		return
	growable.shuffle()
	var grown := 0
	while grown < expansions:
		var space = growable[randi() % growable.size()]
		if _grow_one_direction(space, is_starting_space):
			grown += 1
			
func _grow_one_direction(space, is_starting_space := false):
	var open_dirs := []
	for dir in range(6):
		var target_coord = space.coord + DIR_OFFSETS[dir]
		if space.links[dir] == null and not spaces.has(target_coord):
			open_dirs.append(dir)
	if open_dirs.is_empty():
		return false
	var dir = open_dirs[randi() % open_dirs.size()]
	var target_coord = space.coord + DIR_OFFSETS[dir]
	if _hex_dist_from_center(target_coord) > MAX_RADIUS:
		return false
	_create_space(target_coord, is_starting_space)
	return true
