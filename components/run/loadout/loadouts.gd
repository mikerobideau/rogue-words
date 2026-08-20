extends Control
class_name LoadoutSelect

signal loadout_selected(data: LoadoutData)
signal cancelled()

@onready var display = $Window/VBox/Nav/Display

var loadouts: Array[LoadoutData] = []
var current_index := 0
var current_card: Loadout

func _ready() -> void:
	loadouts = LoadoutFactory.load_all_loadouts()
	_show_current()

func _show_current() -> void:
	if loadouts.is_empty():
		return
	current_index = wrapi(current_index, 0, loadouts.size())
	if current_card:
		current_card.queue_free()
	current_card = LoadoutFactory.create_scene(loadouts[current_index])
	display.add_child(current_card)

func _on_prev_button_pressed() -> void:
	current_index -= 1
	_show_current()

func _on_next_button_pressed() -> void:
	current_index += 1
	_show_current()

func _on_start_button_pressed() -> void:
	if not loadouts.is_empty():
		loadout_selected.emit(loadouts[current_index])
