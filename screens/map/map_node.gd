extends Control
class_name MapNode

enum Type { ROUND, SHOP, UPGRADE, PICKUP }

signal selected(node: MapNode)

var type: int = Type.ROUND
var config: Dictionary = {}
var next: Array = []
var row := 0
var col := 0
var visited := false
var reachable := false

var _button: Button

func _ready():
	custom_minimum_size = Vector2(150, 72)
	_button = Button.new()
	_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_button.pressed.connect(_on_pressed)
	add_child(_button)
	_refresh()

func setup(t: int, c: Dictionary) -> void:
	type = t
	config = c
	if _button:
		_refresh()

func _label() -> String:
	match type:
		Type.ROUND:
			return "Round  (diff " + str(config.get("difficulty", 1)) + ")"
		Type.SHOP:
			return "Shop  (" + str(config.get("num_offers", 2)) + "+" + str(config.get("num_packs", 2)) + ")"
		Type.UPGRADE:
			return "Upgrade a relic"
		Type.PICKUP:
			return "Free pickup"
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
	if not _button:
		return
	_button.text = _label()
	_button.disabled = not reachable
	if visited:
		modulate = Color(0.6, 0.85, 0.6, 1.0)
	elif reachable:
		modulate = Color.WHITE
	else:
		modulate = Color(1, 1, 1, 0.4)
