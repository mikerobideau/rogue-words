extends MarginContainer
class_name RelicContainer

@onready var relics = $Relics

func setup(active_relics: Array[Relic]):
	for relic in active_relics:
		relics.add_child(relic)
