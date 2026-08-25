extends Node
class_name SpaceFactoryGlobal

var SpaceScene = preload("res://components/space/space.tscn")
var StandardSpace = preload("res://components/space/data/space/standard_space.tres")
var JuiceSpace = preload("res://components/space/data/juice_space/juice_space.tres")
var MultSpace = preload("res://components/space/data/mult_space/mult_space.tres")
var PoisonJuiceSpace = preload("res://components/space/data/poison_juice/poison_juice.tres")
var PoisonMultSpace = preload("res://components/space/data/poison_mult/poison_mult.tres")

const ENHANCED_PROBABILITY = 0.2

func create_random_scene() -> Space:
	var data = create_random_data()
	return create_scene(data)

func create_scene(data: SpaceData) -> Space:
	var scene = SpaceScene.instantiate()
	scene.data = data
	return scene

func create_poison_data() -> SpaceData:
	return [PoisonJuiceSpace, PoisonMultSpace].pick_random()

func create_random_data() -> SpaceData:
	var data: SpaceData
	if randf() < ENHANCED_PROBABILITY:
		var enhanced_spaces = [JuiceSpace, MultSpace]
		return enhanced_spaces.pick_random()
	else:
		return StandardSpace
