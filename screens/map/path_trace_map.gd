extends Control
class_name PathTraceMap

signal node_selected(node: MapNode)

const NUM_ROWS = 7
const COLS = 5
const NUM_PATHS = 5
const CELL_SIZE := Vector2(120, 120)
const LINK_COLOR := Color(0.42, 0.28, 0.13)
const LINK_WIDTH := 6.0

const MapNodeScene = preload("res://screens/map/map_node.tscn")

var grid := {}    # Vector2i(col, row) -> MapNode
var edges := {}   # "row,from,to" -> true (for crossing checks)

@onready var rows = $Rows

func _ready() -> void:
	_generate()
	_render()
	resized.connect(queue_redraw)
	await get_tree().process_frame
	queue_redraw()

#--- generation ---

func _generate() -> void:
	grid.clear()
	edges.clear()
	var center := COLS / 2
	_node_at(0, center)
	for p in range(NUM_PATHS):
		_trace_path(center)
	var boss := _node_at(NUM_ROWS - 1, center)
	for col in range(COLS):
		var top = grid.get(Vector2i(col, NUM_ROWS - 2))
		if top and boss not in top.next:
			top.next.append(boss)
	_assign_types()

func _trace_path(start_col: int) -> void:
	var col := start_col
	var node: MapNode = grid[Vector2i(start_col, 0)]
	for row in range(1, NUM_ROWS - 1):
		var next_col := _choose_next(row - 1, col)
		var child := _node_at(row, next_col)
		if child not in node.next:
			node.next.append(child)
		_mark_edge(row - 1, col, next_col)
		node = child
		col = next_col

func _choose_next(from_row: int, col: int) -> int:
	var options := []
	for nc in [col - 1, col, col + 1]:
		if nc < 0 or nc >= COLS:
			continue
		if nc != col and _would_cross(from_row, col, nc):
			continue
		options.append(nc)
	if options.is_empty():
		return col
	return options[randi() % options.size()]

func _would_cross(from_row: int, col: int, nc: int) -> bool:
	if nc == col + 1:
		return edges.has(_edge_key(from_row, col + 1, col))
	if nc == col - 1:
		return edges.has(_edge_key(from_row, col - 1, col))
	return false

func _mark_edge(row: int, from_col: int, to_col: int) -> void:
	edges[_edge_key(row, from_col, to_col)] = true

func _edge_key(row: int, from_col: int, to_col: int) -> String:
	return str(row) + "," + str(from_col) + "," + str(to_col)

func _node_at(row: int, col: int) -> MapNode:
	var key := Vector2i(col, row)
	if grid.has(key):
		return grid[key]
	var node = MapNodeScene.instantiate()
	node.row = row
	node.col = col
	grid[key] = node
	return node

func _assign_types() -> void:
	var parents := {}
	for node in grid.values():
		for child in node.next:
			if not parents.has(child):
				parents[child] = []
			parents[child].append(node)
	# bottom to top, so a node's parents are typed before it
	for row in range(NUM_ROWS):
		for col in range(COLS):
			var node = grid.get(Vector2i(col, row))
			if node == null:
				continue
			var type: int
			if row == 0 or row == NUM_ROWS - 1:
				type = MapNode.Type.ROUND
			else:
				type = _pick_type(row, parents.get(node, []))
			node.setup(type, {})

func _pick_type(row: int, parent_nodes: Array) -> int:
	var parent_types := {}
	for p in parent_nodes:
		parent_types[p.type] = true
	var weights := _weights_for_row(row)
	var pool := []
	var total := 0
	for t in weights:
		# a non-Round type can't immediately follow the same type
		if t != MapNode.Type.ROUND and parent_types.has(t):
			continue
		pool.append({ "type": t, "w": weights[t] })
		total += weights[t]
	var r := randi() % total
	for entry in pool:
		r -= entry.w
		if r < 0:
			return entry.type
	return MapNode.Type.ROUND

func _weights_for_row(row: int) -> Dictionary:
	var w := {
		MapNode.Type.ROUND: 5,
		MapNode.Type.SHOP: 1,
		MapNode.Type.UPGRADE: 1,
		MapNode.Type.PICKUP: 1,
	}
	var mid := (NUM_ROWS - 1) / 2.0
	if absf(row - mid) <= 1.0:
		w[MapNode.Type.SHOP] = 3          # shops peak mid-map
	if row >= NUM_ROWS - 3:
		w[MapNode.Type.UPGRADE] = 3       # upgrades cluster near the boss
	return w

#--- rendering (boss on top, start on bottom) ---

func _render() -> void:
	for row in range(NUM_ROWS - 1, -1, -1):
		var hbox := HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		for col in range(COLS):
			var cell := CenterContainer.new()
			cell.custom_minimum_size = CELL_SIZE
			hbox.add_child(cell)
			var n = grid.get(Vector2i(col, row))
			if n:
				n.selected.connect(_on_node_selected)
				cell.add_child(n)
		rows.add_child(hbox)

func _on_node_selected(node: MapNode) -> void:
	node_selected.emit(node)

#--- links ---

func _center(node: MapNode) -> Vector2:
	return node.global_position - global_position + node.size / 2.0

func _draw() -> void:
	for node in grid.values():
		var from := _center(node)
		for target in node.next:
			draw_line(from, _center(target), LINK_COLOR, LINK_WIDTH)
