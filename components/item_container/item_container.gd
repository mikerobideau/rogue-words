extends MarginContainer
class_name ItemContainer

signal item_selected(item: Item)

@onready var items = $Items

func refresh_items():
	for child in items.get_children():
		child.queue_free()
	for item in GameState.items:
		items.add_child(ItemFactory.create_scene(item))

func _on_item_selected(item: Item):
	item_selected.emit(item)
