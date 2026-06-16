extends MarginContainer
class_name ItemContainer

signal item_selected(item: Item)

@onready var items = $Items

func setup(active_items: Array[ItemData]):
	for data in active_items:
		var scene = ItemFactory.create_scene(data)
		items.add_child(scene)
		scene.clicked.connect(_on_item_selected)
		
func _on_item_selected(item: Item):
	item_selected.emit(item)
