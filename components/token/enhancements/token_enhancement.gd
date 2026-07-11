extends Resource
class_name TokenEnhancement

signal charged()

@export var enhancement_name: String
@export var sprite_frames: SpriteFrames

func on_placed():
	pass
	
func on_scored():
	pass
	
func get_mult() -> int:
	return 1

func get_plus_score() -> int:
	return 0
