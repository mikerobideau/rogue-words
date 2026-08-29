extends Control
class_name ConvergingMap

signal node_selected(node: MapNode)
signal completed()

const CELL_SIZE := Vector2(120, 120)
const LINK_COLOR := Color(0.42, 0.28, 0.13)
const LINK_WIDTH := 6.0

const MapNodeScene = preload("res://screens/map/map_node.tscn")
const REWARD_TYPES := [MapNode.Type.SHOP, MapNode.Type.UPGRADE, MapNode.Type.PICKUP, MapNode.Type.GOLD]

const TOTAL_ROUNDS := 3
const TOTAL_REWARDS := 5

var grid := {}   # Vector2i(col, row) -> MapNode  (col: 0=left, 1=center, 2=right)
var num_rows := 0
var start_node: MapNode
var current_node: MapNode

@onready var rows = $Rows

func _ready() -> void:
	_generate()
	_render()
	resized.connect(queue_redraw)
	current_node = start_node
	start_node.mark_visited()
	_update_reachable()
	await get_tree().process_frame
	queue_redraw()

#--- generation ---

func _generate() -> void:
	grid.clear()
	var sets := randi_range(2, 4)
	var junction_rounds := sets - 1                     # rounds sitting between branch sets
	var branch_rounds := TOTAL_ROUNDS - junction_rounds # remaining rounds live inside branches
	var rewards_per_set := _partition(TOTAL_REWARDS, sets)
	var rounds_per_set := _distribute(branch_rounds, sets)

	var row := 0
	start_node = _place(row, 1, MapNode.Type.START)
	var prev := start_node
	row += 1

	for s in range(sets):
		var length: int = rewards_per_set[s] + rounds_per_set[s]
		var a_seq := _make_branch(rewards_per_set[s], rounds_per_set[s])
		var b_seq := _make_branch(rewards_per_set[s], rounds_per_set[s])
		var a_prev := prev
		var b_prev := prev
		for i in range(length):
			var a := _place(row, 0, a_seq[i])
			var b := _place(row, 2, b_seq[i])
			a_prev.next.append(a)
			b_prev.next.append(b)
			a_prev = a
			b_prev = b
			row += 1
		var jtype := MapNode.Type.BOSS if s == sets - 1 else MapNode.Type.ROUND
		var j := _place(row, 1, jtype)
		a_prev.next.append(j)
		b_prev.next.append(j)
		prev = j
		row += 1

	num_rows = row

func _make_branch(num_rewards: int, num_rounds: int) -> Array:
	var seq := []
	for i in range(num_rewards):
		seq.append(REWARD_TYPES.pick_random())
	for i in range(num_rounds):
		seq.append(MapNode.Type.ROUND)
	seq.shuffle()
	return seq

func _partition(total: int, parts: int) -> Array:
	var r := []
	for i in range(parts):
		r.append(1)
	for i in range(total - parts):
		r[randi() % parts] += 1
	return r

func _distribute(total: int, parts: int) -> Array:
	var r := []
	for i in range(parts):
		r.append(0)
	for i in range(total):
		r[randi() % parts] += 1
	return r

func _place(row: int, col: int, type: int) -> MapNode:
	var node = MapNodeScene.instantiate()
	node.row = row
	node.col = col
	node.setup(type, _config_for(type, row))
	grid[Vector2i(col, row)] = node
	return node

#--- config (so main can open the matching scene) ---

func _config_for(type: int, row: int) -> Dictionary:
	match type:
		MapNode.Type.ROUND, MapNode.Type.BOSS:
			return _round_config(row, type == MapNode.Type.BOSS)
		MapNode.Type.SHOP:
			var n := randi_range(1, 3)
			return { "num_offers": n, "num_packs": n }
		MapNode.Type.GOLD:
			return { "money": randi_range(5, 15) }
	return {}

func _round_config(row: int, is_boss: bool) -> Dictionary:
	var abilities := BossFactory.load_all_bosses()
	abilities.shuffle()
	var n := 3 if is_boss else clampi(row / 3, 0, 2)
	var chosen := abilities.slice(0, mini(n, abilities.size()))
	var boss := CompositeBoss.new()
	boss.bosses = chosen
	boss.boss_name = "Boss" if is_boss else "Elite"
	var names := []
	for b in chosen:
		names.append(b.boss_name)
	boss.description = ", ".join(names)
	var difficulty := 1 + boss.get_difficulty()
	var reward := { "money": 3 * difficulty, "items": [], "relics": [] }
	if difficulty >= 3:
		reward.items.append(ItemFactory.load_all_items().pick_random())
	if difficulty >= 4:
		var pool := _unowned_relics()
		if not pool.is_empty():
			reward.relics.append(pool.pick_random())
	return { "difficulty": difficulty, "boss": boss, "reward": reward, "target_score": 60 + 40 * difficulty }

func _unowned_relics() -> Array:
	var owned := GameState.relics.map(func(rd): return rd.relic_name)
	return RelicFactory.load_all_relics().filter(func(rd): return rd.relic_name not in owned)

#--- navigation ---

func _update_reachable() -> void:
	for node in grid.values():
		node.set_reachable(node in current_node.next and not node.visited)

func _on_node_selected(node: MapNode) -> void:
	node_selected.emit(node)

func advance(node: MapNode) -> void:
	node.mark_visited()
	current_node = node
	if node.type == MapNode.Type.BOSS:
		completed.emit()
		return
	_update_reachable()

#--- rendering (boss on top, start on bottom) ---

func _render() -> void:
	for row in range(num_rows - 1, -1, -1):
		var hbox := HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		for col in range(3):
			var cell := CenterContainer.new()
			cell.custom_minimum_size = CELL_SIZE
			hbox.add_child(cell)
			var n = grid.get(Vector2i(col, row))
			if n:
				n.selected.connect(_on_node_selected)
				cell.add_child(n)
		rows.add_child(hbox)

#--- links ---

func _center(node: MapNode) -> Vector2:
	return node.global_position - global_position + node.size / 2.0

func _draw() -> void:
	for node in grid.values():
		var from := _center(node)
		for target in node.next:
			draw_line(from, _center(target), LINK_COLOR, LINK_WIDTH)
