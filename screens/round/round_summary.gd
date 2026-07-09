extends CanvasLayer
class_name RoundSummary

signal closed()

@onready var money_reward_label = $Panel/Margin/MoneyRewardLabel

func _on_button_pressed() -> void:
	visible = false
	closed.emit()
