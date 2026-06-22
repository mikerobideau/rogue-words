extends Control
class_name Hud

@onready var relic_container = $Left/Inventory/RelicContainer
@onready var item_container = $Left/Inventory/ItemContainer
@onready var score_panel = $Right/ScorePanel
@onready var left = $Left
@onready var right = $Right

func refresh_relics():
	relic_container.refresh_relics()
	
func get_relics() -> Array[Relic]:
	return relic_container.get_relics()

func refresh_items():
	item_container.refresh_items()

func on_round_complete():
	for child in right.get_children():
		child.queue_free()
