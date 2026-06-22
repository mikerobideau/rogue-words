extends Control
class_name Hud

@onready var relic_container = $RelicContainer

func setup():
	relic_container.setup(GameState.relics)
