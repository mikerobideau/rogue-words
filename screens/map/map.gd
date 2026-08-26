extends Control
class_name Map

signal node_selected(node: MapNode)
signal completed()

const MapNodeScene = preload("res://screens/map/map_node.tscn")
const DEPTH := 8

var rows: Array = []
var current_node: MapNode = null

@onready var _rows_box := VBoxContainer.new()

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	_rows_box.add_theme_constant_override("separation", 40)
	center.add_child(_rows_box)
	_generate()
	_render()
	_update_reachable()

#--- generation ---

func _generate() -> void:
	rows.clear()
	for r in DEPTH:
		var row := []
		var count := 1 if r == DEPTH - 1 else randi_range(2, 3)
		for c in count:
			var node := MapNodeScene.instantiate()
			node.row = r
			node.col = c
			var type := _pick_type(r)
			node.setup(type, _config_for(type, r))
			row.append(node)
		rows.append(row)
	_connect()

func _pick_type(r: int) -> int:
	if r == 0 or r == DEPTH - 1:
		return MapNode.Type.ROUND
	var roll := randf()
	if roll < 0.55:
		return MapNode.Type.ROUND
	elif roll < 0.75:
		return MapNode.Type.SHOP
	elif roll < 0.9:
		return MapNode.Type.UPGRADE
	return MapNode.Type.PICKUP

func _config_for(type: int, r: int) -> Dictionary:
	match type:
		MapNode.Type.ROUND:
			return _round_config(r)
		MapNode.Type.SHOP:
			var n := randi_range(1, 3)
			return { "num_offers": n, "num_packs": n }
		MapNode.Type.PICKUP:
			return { "offers": _pickup_offers() }
	return {}

func _round_config(r: int) -> Dictionary:
	var abilities := BossFactory.load_all_bosses()
	abilities.shuffle()
	var n := 3 if r == DEPTH - 1 else randi_range(0, mini(1 + r / 2, 2))
	var chosen := abilities.slice(0, mini(n, abilities.size()))
	var boss := CompositeBoss.new()
	boss.bosses = chosen
	boss.boss_name = "Elite"
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

func _pickup_offers() -> Array:
	var offers := []
	var items := ItemFactory.load_all_items()
	var relics := _unowned_relics()
	for i in 3:
		if relics.size() > 0 and randf() < 0.5:
			offers.append({ "kind": "relic", "data": relics.pick_random() })
		elif items.size() > 0:
			offers.append({ "kind": "item", "data": items.pick_random() })
	return offers

func _unowned_relics() -> Array:
	var owned := GameState.relics.map(func(rd): return rd.relic_name)
	return RelicFactory.load_all_relics().filter(func(rd): return rd.relic_name not in owned)

func _connect() -> void:
	for r in range(rows.size() - 1):
		var this_row: Array = rows[r]
		var next_row: Array = rows[r + 1]
		var incoming := {}
		for node in this_row:
			var count := randi_range(1, mini(2, next_row.size()))
			var idxs := range(next_row.size())
			idxs.shuffle()
			for i in count:
				var idx = idxs[i]
				if idx not in node.next:
					node.next.append(idx)
					incoming[idx] = true
		for i in next_row.size():
			if not incoming.has(i):
				this_row[randi() % this_row.size()].next.append(i)

#--- rendering ---

func _render() -> void:
	for row in rows:
		var hbox := HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 30)
		for node in row:
			node.selected.connect(_on_node_selected)
			hbox.add_child(node)
		_rows_box.add_child(hbox)

func _update_reachable() -> void:
	var reachable_set := []
	if current_node == null:
		reachable_set = rows[0]
	elif current_node.row + 1 < rows.size():
		var next_row: Array = rows[current_node.row + 1]
		for idx in current_node.next:
			reachable_set.append(next_row[idx])
	for row in rows:
		for node in row:
			if not node.visited:
				node.set_reachable(node in reachable_set)

func _on_node_selected(node: MapNode) -> void:
	node_selected.emit(node)

func advance(node: MapNode) -> void:
	node.mark_visited()
	current_node = node
	if node.row == rows.size() - 1:
		completed.emit()
		return
	_update_reachable()
