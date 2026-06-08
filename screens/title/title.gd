extends Control
class_name Title

signal new_game()

func _on_play_button_pressed():
	print_debug('new game pressed')
	new_game.emit()
