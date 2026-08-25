extends Resource
class_name ItemData

signal data_changed()

@export var item_name: String
@export var icon: Texture2D
@export var cost := 3
@export var description: String
@export var can_enhance_token := false
@export var affects_board := false

func enhance_token(token: Token) -> bool:
	return false

func use_on_board(board, target) -> bool:
	return false
