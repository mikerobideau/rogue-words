extends Control
class_name Hud

@onready var relic_container = $Left/Inventory/RelicContainer
@onready var item_container = $Left/Inventory/ItemContainer
@onready var score_panel = $Right/ScorePanel

func refresh_relics():
	relic_container.refresh_relics()
	
func get_relics() -> Array[Relic]:
	return relic_container.get_relics()

func refresh_items():
	item_container.refresh_items()
