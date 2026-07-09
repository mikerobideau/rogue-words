extends Control
class_name GameOver

signal new_game()

@onready var subtitle_label = $Body/VBoxContainer/Subtitle

var subtitle := '':
	set(v):
		subtitle = v
		subtitle_label.text = v
		
func _on_play_button_pressed():
	new_game.emit()
