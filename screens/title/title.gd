extends Control
class_name Title

signal new_game(data: LoadoutData)

@onready var loadouts = $Panel/VBox/RunMenu/Loadouts

func _ready():
	loadouts.loadout_selected.connect(_on_loadout_selected)

func _on_loadout_selected(data: LoadoutData):
	new_game.emit(data)
