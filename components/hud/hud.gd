extends Control
class_name Hud

@onready var title_label = $Header/InnerMargin/Title
@onready var money = $Header/InnerMargin/Money
@onready var relic_container = $Right/CenterContainer/Inventory/RelicContainer
@onready var item_container = $Right/CenterContainer/Inventory/ItemContainer

@export var title: String:
	set(v):
		title = v
		title_label.text = v

func get_relics() -> Array[Relic]:
	return relic_container.get_relics()

func on_round_complete():
	pass
