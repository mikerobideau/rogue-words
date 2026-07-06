extends CanvasLayer
class_name SlotMenuGloabl

const SlotMenuScene := preload("res://components/slot_menu/slot_menu_node.tscn")
const GAP := 8.0

var menu: SlotMenuNode
var backdrop: Control
var current_target: Control

func _ready() -> void:
	layer = 90
	backdrop = _create_backdrop()
	add_child(backdrop)                 # added first → drawn under the menu
	menu = SlotMenuScene.instantiate()
	menu.visible = false
	add_child(menu)                     # added last → drawn on top of backdrop
	menu.closed.connect(close)
	backdrop.gui_input.connect(_on_backdrop_input)

# actions: Array of { "text": String, "callback": Callable }
func open(target: Control, actions: Array) -> void:
	current_target = target
	menu.set_actions(actions)
	backdrop.visible = true
	menu.visible = true
	await get_tree().process_frame      # let the panel size to its buttons
	_position_menu(target)

func close() -> void:
	menu.visible = false
	backdrop.visible = false
	current_target = null

func _create_backdrop() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_STOP   # catches clicks outside the menu
	c.visible = false
	return c

func _on_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()

func _position_menu(target: Control) -> void:
	var target_rect := target.get_global_rect()
	var menu_size := menu.size

	# centered under the slot by default
	var pos := Vector2(
		target_rect.position.x + (target_rect.size.x - menu_size.x) / 2.0,
		target_rect.position.y + target_rect.size.y + GAP
	)

	var viewport_size := get_viewport().get_visible_rect().size

	# flip above the slot if it would run off the bottom
	if pos.y + menu_size.y > viewport_size.y - 4.0:
		pos.y = target_rect.position.y - menu_size.y - GAP

	pos.x = clamp(pos.x, 4.0, viewport_size.x - menu_size.x - 4.0)
	pos.y = max(pos.y, 4.0)

	menu.global_position = pos
