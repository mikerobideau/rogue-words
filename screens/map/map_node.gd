extends TextureButton
class_name MapNode

enum Type { ROUND, SHOP, UPGRADE, PICKUP, GOLD, BOSS, START }

@onready var label = $Label

signal selected(node: MapNode)

var type: int = Type.ROUND
var config: Dictionary = {}
var next: Array = []
var row := 0
var col := 0
var visited := false
var reachable := false

func _ready():
	pressed.connect(_on_pressed)
	_refresh()

func setup(t: int, c: Dictionary) -> void:
	type = t
	config = c
	_refresh()

func _get_label() -> String:
	match type:
		Type.ROUND:
			return 'Round'
		Type.SHOP:
			return 'Shop'
		Type.UPGRADE:
			return 'Upgrade'
		Type.PICKUP:
			return 'Pickup'
		Type.GOLD:
			return 'Gold'
		Type.BOSS:
			return 'Boss'
		Type.START:
			return 'Start'
	return "?"

func _on_pressed() -> void:
	if reachable:
		selected.emit(self)

func set_reachable(v: bool) -> void:
	reachable = v
	_refresh()

func mark_visited() -> void:
	visited = true
	reachable = false
	_refresh()

func _refresh() -> void:
	if label:
		label.text = _get_label()
	if visited:
		modulate = Color(0.5, 0.5, 0.5, 1.0)
	elif reachable:
		modulate = Color(1.0, 0.95, 0.4, 1.0)
	else:
		modulate = Color(1.0, 1.0, 1.0, 0.55)
