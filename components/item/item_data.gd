extends Resource
class_name ItemData

signal data_changed()

@export var item_name: String
@export var description: String
@export var can_enhance_token := false

func enhance_token(token: Token) -> bool:
	return false
