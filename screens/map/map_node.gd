extends Control
class_name MapNode

enum Type { ROUND, SHOP, UPGRADE, PICKUP }

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
	pass

func setup(t: int, c: Dictionary) -> void:
	type = t
	config = c

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
	label.text = _get_label()
	#self.disabled = not reachable
	#if visited:
	#	modulate = Color(0.6, 0.85, 0.6, 1.0)
	#elif reachable:
	#	modulate = Color.WHITE
	#else:
#		modulate = Color(1, 1, 1, 0.4)
