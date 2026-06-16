extends Node
class_name ItemManager

signal items_changed(items: Array[Item])

var ItemScene = preload("res://components/item/item.tscn")

func _on_item_played(item: Item):
	GameState.items.erase(item.data)
	item.queue_free()
