extends Resource
class_name TokenEnhancement

signal charged()

@export var enhancement_name: String
@export var adjective: String
@export var description: String
@export var sprite_frames: SpriteFrames

func on_placed():
	pass
	
func on_scored(token: Token):
	pass
	
func get_mult() -> int:
	return 0
