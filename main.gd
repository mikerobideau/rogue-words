extends Control

var SCREENS = {
	'title':  preload("res://screens/title/title.tscn"),
	'round': preload("res://screens/round/round.tscn")
}

var current_screen: Control = null

func _ready():
	size = get_viewport().get_visible_rect().size
	_show_title()
	
func _show_title():
	var title = SCREENS.title.instantiate()
	_show_screen(title)
	title.new_game.connect(_on_new_game)
	
func _on_new_game():
	GameState.set_round_number(1)
	var round = SCREENS.round.instantiate()
	_show_screen(round)
	
func _show_screen(screen: Control):
	if current_screen:
		current_screen.queue_free()
		current_screen = null
	current_screen = screen
	add_child(current_screen)
