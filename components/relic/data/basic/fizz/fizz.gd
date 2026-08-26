extends RelicData
class_name Fizz

@export var value: int

func get_mult(context: RelicContext) -> int:
	return value

func upgrade() -> void:
	value += 1
	super()

func get_upgrade_text() -> String:
	return '+1 mult'
