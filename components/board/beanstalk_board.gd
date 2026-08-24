extends Control
class_name BeanstalkBoard

# Grows a vine upward from a single sprout at the bottom of the screen, inside
# a fixed MAX_ROWS x MAX_COLS region so it can never spill off the board.
#
# Growth is a draft: each turn the vine offers DRAFT_SIZE buds, drawn at random
# from anywhere it can legally grow. The player places their token on one,
# promoting it into a real space. Half of the buds they passed over bloom into
# leaves; the rest wither. The offers are unbiased -- the silhouette is authored
# entirely by which buds the player takes.

signal space_clicked(space: Space)
signal space_hovered(space: Space)

const DEFAULT_NUM_STARTING_SPACES = 1
const NUM_EXPANSIONS = 1
const SPACING := 90
const SQRT_3_OVER_2 = sqrt(3) / 2.0	

# buds offered per turn, and how many of the ones the player passed over turn
# into leaves. Deterministic on purpose: every turn grows exactly one playable
# space and one leaf, whether or not a word scored. Raising LEAVES_PER_DRAFT
# to 2 saturates the box and growth stalls well before turn 12.
const DRAFT_SIZE := 3
const LEAVES_PER_DRAFT := 1
const BUD_ALPHA := 0.55

# no space may touch more than this many others -- keeps the stalk a vine
# instead of a blob
const MAX_EDGES := 3

# hard bounding box in tiles, measured from the sprout and enforced by
# _can_create. Nothing may grow below the sprout's row, more than MAX_ROWS - 1
# above it, or more than half of MAX_COLS to either side -- so the vine can
# never leave the board. A draft of 3 needs the full 7 columns of room; at 5
# the vine runs out of legal positions well before turn 12.
const MAX_ROWS := 7
const MAX_COLS := 7

const BOTTOM_MARGIN := 120.0
const TOP_MARGIN := 60.0

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
var max_spaces := 0              # set by Round; 0 = unbounded

var spaces: Dictionary = {}      # coord -> Space, promoted spaces only

var _draft: Array = []           # buds awaiting the player's choice
var _leaf_count := 0             # leaf spaces, excluded from the max_spaces budget

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_anchor_stalk)

# turn one is a single sprout with nothing to choose between -- the draft
# starts once the first token is down and grow() is called
func start():
	_create_space(start_space_coord)
	for i in maxi(num_starting_spaces - 1, 0):
		var extra := _draft_coords(1)
		if extra.is_empty():
			break
		_create_space(extra[0])

func get_spaces():
	return spaces

# Round calls this to place the turn's token. If the target is a bud, choosing
# it resolves the whole draft before the token lands, so the space is linked
# into the word graph first.
func place(token: Token, space: Space):
	if space in _draft:
		_resolve_draft(space)
	space.place_token(token)

func highlight(path: Array):
	for space in path:
		space.token.pulse()

#--- draft ---

# extra expansions (from relics) widen the draft rather than growing twice
func grow(expansions: int):
	_offer_draft(DRAFT_SIZE + expansions - NUM_EXPANSIONS)

func _offer_draft(count: int) -> void:
	_clear_draft()
	if max_spaces > 0 and _playable_count() >= max_spaces:
		return
	var coords := _draft_coords(count)
	if coords.is_empty():
		push_warning("Beanstalk is boxed in -- no legal buds to offer")
		return
	for coord in coords:
		_draft.append(_create_bud(coord))
	_anchor_stalk()

# the chosen bud becomes the player's space; exactly LEAVES_PER_DRAFT of the
# buds passed over bloom into leaves and the rest wither. Which one blooms is
# random, but how many is not -- growth is the same every turn.
func _resolve_draft(chosen: Space) -> void:
	_promote_bud(chosen)
	var passed := []
	for bud in _draft:
		if bud != chosen:
			passed.append(bud)
	passed.shuffle()
	var leaves_left := LEAVES_PER_DRAFT
	for bud in passed:
		# re-validated per bud: promoting the chosen bud, or an earlier leaf,
		# may have used up a neighbour's last free edge
		if leaves_left > 0 and _can_create(bud.coord):
			bud.data = SpaceFactory.StandardSpace
			_promote_bud(bud)
			_leaf_count += 1
			bud.place_token(TokenFactory.create_leaf())
			leaves_left -= 1
		else:
			_wither_bud(bud)
	_draft.clear()
	_anchor_stalk()

func _clear_draft() -> void:
	for bud in _draft:
		if is_instance_valid(bud):
			_wither_bud(bud)
	_draft.clear()

# a bud that is not taken must drop its links, or its neighbours keep
# references to a freed node and word_finder walks into garbage
func _wither_bud(bud: Space) -> void:
	for dir in range(6):
		var neighbor = bud.links[dir]
		if neighbor != null and is_instance_valid(neighbor):
			neighbor.links[(dir + 3) % 6] = null
		bud.links[dir] = null
	bud.queue_free()

func _playable_count() -> int:
	return spaces.size() - _leaf_count

# buds are drawn at random from anywhere the vine can legally grow, rather
# than clustered near the tip -- the player's picks are what shape the stalk
func _draft_coords(count: int) -> Array:
	var candidates := _legal_coords()
	candidates.shuffle()
	return candidates.slice(0, mini(count, candidates.size()))

# every legal coord touching the vine, anywhere on the board
func _legal_coords() -> Array:
	var seen := {}
	var result := []
	for space in spaces.values():
		for offset in DIR_OFFSETS:
			var coord: Vector2i = space.coord + offset
			if seen.has(coord) or not _can_create(coord):
				continue
			seen[coord] = true
			result.append(coord)
	return result

#--- creation ---

# a coord may be created only if it stays inside the bounding box, and neither
# it nor any existing neighbor would end up touching more than MAX_EDGES spaces
func _can_create(coord: Vector2i) -> bool:
	if spaces.has(coord):
		return false
	if not _within_bounds(coord):
		return false
	if _neighbor_count(coord) > MAX_EDGES:
		return false
	for offset in DIR_OFFSETS:
		var n = coord + offset
		if spaces.has(n) and _neighbor_count(n) >= MAX_EDGES:
			return false
	return true

# the board is a fixed region anchored on the sprout: never below it, never
# more than MAX_ROWS - 1 above, never more than half of MAX_COLS to a side
func _within_bounds(coord: Vector2i) -> bool:
	var rows_up := start_space_coord.y - coord.y
	if rows_up < 0:
		return false                      # nothing may grow below the sprout
	if rows_up > MAX_ROWS - 1:
		return false
	# _col counts half-columns, so MAX_COLS - 1 of them is half the width
	if absi(_col(coord) - _col(start_space_coord)) > MAX_COLS - 1:
		return false
	return true

func _neighbor_count(coord: Vector2i) -> int:
	var count := 0
	for offset in DIR_OFFSETS:
		if spaces.has(coord + offset):
			count += 1
	return count

# a bud is a real Space node so the player can click it, but it is kept out of
# `spaces` and unlinked until promoted -- word_finder must not walk through it
func _create_bud(coord: Vector2i) -> Space:
	var space = SpaceFactory.create_random_scene()
	space.coord = coord
	space.position = _coord_to_pixel(coord)
	space_container.add_space(space)
	space.clicked.connect(_on_space_clicked)
	space.hovered.connect(_on_space_hovered)
	space.enabled = true
	space.modulate.a = BUD_ALPHA
	# linked while still a bud so hovering it can preview a word. Safe because
	# word_finder only ever traverses INTO spaces that hold a token.
	_link_neighbors(space)
	space.pop_open()
	return space

func _promote_bud(bud: Space) -> void:
	spaces[bud.coord] = bud
	_link_neighbors(bud)
	_grow_links(bud)
	bud.modulate.a = 1.0
	bud.pop_open()
	if bud.has_enhancement():
		Sound.play(Sound.SOUND_ENHANCED_SPACE)

func _grow_links(space: Space) -> void:
	for dir in range(6):
		var neighbor = space.links[dir]
		if neighbor != null:
			space_container.add_link(space, neighbor)

func _create_space(coord: Vector2i, space_data: SpaceData = null) -> Space:
	var space = SpaceFactory.create_scene(space_data) if space_data \
		else SpaceFactory.create_random_scene()
	space.coord = coord
	space.position = _coord_to_pixel(coord)
	space_container.add_space(space)
	space.clicked.connect(_on_space_clicked)
	space.hovered.connect(_on_space_hovered)
	space.enabled = true
	_promote_bud(space)
	_anchor_stalk()
	return space

func _link_neighbors(space: Space):
	for dir in range(6):
		var neighbor_coord = space.coord + DIR_OFFSETS[dir]
		var neighbor = spaces.get(neighbor_coord)
		if neighbor != null and neighbor != space:
			space.links[dir] = neighbor
			neighbor.links[(dir + 3) % 6] = space

#--- geometry ---

# pins the root space at bottom-center so the vine climbs from a fixed base
func _anchor_stalk() -> void:
	if not space_container.has_spaces:
		return
	var root := _coord_to_pixel(start_space_coord)
	var x := size.x / 2.0 - root.x
	var y := size.y - BOTTOM_MARGIN - root.y
	# once the vine outgrows the view, scroll so the growing tip stays visible
	var overflow := (y + space_container.bounds.position.y) - TOP_MARGIN
	if overflow < 0.0:
		y -= overflow
	space_container.position = Vector2(x, y)

# horizontal position in half-column units: adjacent tiles in the same row
# differ by 2, diagonal neighbours by 1. Two half-columns = one tile wide.
func _col(coord: Vector2i) -> int:
	return coord.x * 2 + coord.y

func _coord_to_pixel(coord: Vector2i) -> Vector2:
	var x = SPACING * SQRT_3_OVER_2 * (coord.x * 2 + coord.y) + start_space_pos.x
	var y = SPACING * 1.5 * coord.y + start_space_pos.y
	return Vector2(x, y)

func _on_space_clicked(space: Space):
	space_clicked.emit(space)

func _on_space_hovered(space: Space):
	space_hovered.emit(space)
