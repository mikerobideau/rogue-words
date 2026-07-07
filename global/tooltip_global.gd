extends CanvasLayer

const TooltipScene := preload("res://components/tooltip/tooltip_node.tscn")
const GAP := 8.0

var tooltip: PanelContainer
var current_target: Control
var tooltip_texts: Dictionary = {}  # target -> text

func _ready() -> void:
	layer = 100
	tooltip = TooltipScene.instantiate()
	tooltip.visible = false
	add_child(tooltip)

func register(target: Control, text: String) -> void:
	tooltip_texts[target] = text
	if not target.mouse_entered.is_connected(_on_target_entered):
		target.mouse_entered.connect(_on_target_entered.bind(target))
		target.mouse_exited.connect(_on_target_exited.bind(target))
		target.tree_exiting.connect(_on_target_freed.bind(target))

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
		tooltip.visible = false
		current_target = null

func _on_target_entered(target: Control) -> void:
	current_target = target
	tooltip.set_text(tooltip_texts.get(target, ""))
	_position_tooltip(target)
	tooltip.visible = true

func _on_target_exited(target: Control) -> void:
	if current_target == target:
		tooltip.visible = false
		current_target = null

func _on_target_freed(target: Control) -> void:
	tooltip_texts.erase(target)
	if current_target == target:
		tooltip.visible = false
		current_target = null

func _position_tooltip(target: Control) -> void:
	var target_rect := target.get_global_rect()
	var tooltip_size := tooltip.size

	var pos := Vector2(
		target_rect.position.x - tooltip_size.x - GAP,
		target_rect.position.y + (target_rect.size.y - tooltip_size.y) / 2.0
	)

	var viewport_size := get_viewport().get_visible_rect().size
	pos.x = max(pos.x, 4.0)
	pos.y = clamp(pos.y, 4.0, viewport_size.y - tooltip_size.y - 4.0)

	tooltip.global_position = pos
