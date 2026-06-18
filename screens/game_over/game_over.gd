extends Control
class_name GameOver

signal new_game()

func _on_play_button_pressed():
	new_game.emit()
