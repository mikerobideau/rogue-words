extends Control
class_name SlotMenuNode

signal closed

@onready var actions_container = $Actions

func set_actions(actions: Array) -> void:
	_clear()
	for action in actions:
		var button := Button.new()
		button.text = action["text"]
		button.pressed.connect(_on_action_pressed.bind(action["callback"]))
		actions_container.add_child(button)

func _clear() -> void:
	for child in actions_container.get_children():
		child.queue_free()

func _on_action_pressed(callback: Callable) -> void:
	callback.call()
	closed.emit()
