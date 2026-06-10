extends MarginContainer
class_name ItemContainer

signal item_selected(item: Item)

@onready var items = $Items

func setup(active_items: Array[Item]):
	refresh(active_items)
	
func refresh(active_items: Array[Item]):
	for child in items.get_children():
		child.queue_free()
	for item in active_items:
		items.add_child(item)
		item.clicked.connect(_on_item_selected)
		
func _on_item_selected(item: Item):
	item_selected.emit(item)
