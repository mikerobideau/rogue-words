extends CanvasLayer

const TooltipScene := preload("res://components/tooltip/tooltip_node.tscn")
const GAP := 8.0

var tooltip: PanelContainer
var current_target: Control
var tooltip_texts: Dictionary = {}

func _ready() -> void:
	layer = 100

func register(target: Control, text: String) -> void:
	tooltip_texts[target] = text
	var entered := _on_target_entered.bind(target)
	if not target.mouse_entered.is_connected(entered):
		target.mouse_entered.connect(entered)
		target.mouse_exited.connect(_on_target_exited.bind(target))
		target.tree_exiting.connect(_on_target_freed.bind(target))
	if current_target == target and tooltip:
		_present_for_control(target)

func unregister(target: Control) -> void:
	tooltip_texts.erase(target)
	var entered := _on_target_entered.bind(target)
	var exited := _on_target_exited.bind(target)
	var freed := _on_target_freed.bind(target)
	if target.mouse_entered.is_connected(entered):
		target.mouse_entered.disconnect(entered)
	if target.mouse_exited.is_connected(exited):
		target.mouse_exited.disconnect(exited)
	if target.tree_exiting.is_connected(freed):
		target.tree_exiting.disconnect(freed)
	if current_target == target:
		_clear_tooltip()
		current_target = null

func _on_target_entered(target: Control) -> void:
	current_target = target
	_present_for_control(target)

func _on_target_exited(target: Control) -> void:
	if current_target == target:
		_clear_tooltip()
		current_target = null

func _on_target_freed(target: Control) -> void:
	tooltip_texts.erase(target)
	if current_target == target:
		_clear_tooltip()
		current_target = null

# --- lifecycle ---

func _spawn_tooltip(text: String) -> void:
	_clear_tooltip()
	tooltip = TooltipScene.instantiate()
	tooltip.visible = false
	add_child(tooltip)
	tooltip.set_text(text)

func _clear_tooltip() -> void:
	if is_instance_valid(tooltip):
		tooltip.hide()
		tooltip.queue_free()
	tooltip = null

func _present_for_control(target: Control) -> void:
	_spawn_tooltip(tooltip_texts.get(target, ""))
	_position_tooltip(target)
	tooltip.visible = true

# --- positioning ---

func _position_tooltip(target: Control) -> void:
	if not tooltip:
		return
	var target_rect := target.get_global_rect()
	var tooltip_size := tooltip.size

	var pos := Vector2(
		target_rect.position.x - tooltip_size.x - GAP,
		target_rect.position.y
	)

	var viewport_size := get_viewport().get_visible_rect().size
	pos.x = max(pos.x, 4.0)
	pos.y = clamp(pos.y, 4.0, viewport_size.y - tooltip_size.y - 4.0)

	tooltip.global_position = pos

# --- Node2D variant ---

func show_for_node(target: Node2D, text: String) -> void:
	if not is_instance_valid(target):
		return
	_spawn_tooltip(text)
	var screen_pos := target.get_global_transform_with_canvas().origin
	await get_tree().process_frame
	if not tooltip:
		return
	tooltip.global_position = Vector2(
		screen_pos.x - tooltip.size.x / 2.0,
		screen_pos.y - tooltip.size.y - GAP - Token.RADIUS)
	tooltip.visible = true

func hide_for_node() -> void:
	_clear_tooltip()
