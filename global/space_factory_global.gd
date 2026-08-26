extends Node
class_name SpaceFactoryGlobal

var SpaceScene = preload("res://components/space/space.tscn")
var StandardSpace = preload("res://components/space/data/space/standard_space.tres")
var JuiceSpace = preload("res://components/space/data/juice_space/juice_space.tres")
var MultSpace = preload("res://components/space/data/mult_space/mult_space.tres")
var MoneySpace = preload("res://components/space/data/money_space/money_space.tres")
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
	if randf() < 0.5:
		var d = PoisonJuiceSpace.duplicate()
		d.juice = -randi_range(1, 10)
		return d
	var m = PoisonMultSpace.duplicate()
	m.mult = -randi_range(1, 4)
	return m

func create_random_data() -> SpaceData:
	if randf() < ENHANCED_PROBABILITY:
		match randi() % 3:
			0:
				var d = JuiceSpace.duplicate()
				d.juice = randi_range(1, 10)
				return d
			1:
				var m = MultSpace.duplicate()
				m.mult = randi_range(1, 4)
				return m
			_:
				var mo = MoneySpace.duplicate()
				mo.money = randi_range(1, 5)
				mo.required_letter = TokenFactory.LETTERS.keys().pick_random()
				return mo
	return StandardSpace
