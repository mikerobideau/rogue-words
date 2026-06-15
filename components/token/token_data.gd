extends Resource
class_name TokenData

enum Type {
	GRAPE,
	GREEN_GRAPE,
	YELLOW_GRAPE,
	CLOVER
}

@export var type: Type
@export var letter: String
@export var value: int
