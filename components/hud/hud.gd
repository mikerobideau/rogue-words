extends Control
class_name Hud

@onready var money = $HeaderMargin/Money
@onready var relic_container = $Right/InventoryContainer/Inventory/RelicContainer
@onready var item_container = $Right/InventoryContainer/Inventory/ItemContainer

func get_relics() -> Array[Relic]:
	return relic_container.get_relics()

func on_round_complete():
	pass
