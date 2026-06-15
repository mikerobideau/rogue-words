extends HBoxContainer
class_name DiscardUI

signal discard_clicked()
signal cancel_discard_clicked()
signal confirm_discard_clicked()

@onready var discard_button = $Discard
@onready var cancel_button = $CancelDiscard
@onready var confirm_button = $ConfirmDiscard

@export var discard_text: String = 'DISCARD':
	set(v):
		discard_text = v
		discard_button.text = v

@export var discard_disabled: bool = false:
	set(v):
		print_debug('setting discard disabled to ' + str(v))
		discard_disabled = v
		discard_button.disabled = v

@export var confirm_text: String = 'DISCARD':
	set(v):
		confirm_text = v
		confirm_button.text = v
		
@export var confirm_disabled: bool = true:
	set(v):
		confirm_disabled = v
		confirm_button.disabled = v
		
var in_progress := false:
	set(v):
		in_progress = v
		_update_button_visibility()
		
func _ready():
	in_progress = false

func _on_discard_pressed() -> void:
	in_progress = true
	discard_clicked.emit()

func _on_cancel_discard_pressed() -> void:
	in_progress = false
	cancel_discard_clicked.emit()

func _on_confirm_discard_pressed() -> void:
	in_progress = false
	confirm_discard_clicked.emit()
	
func _update_button_visibility():
	discard_button.visible = !in_progress
	cancel_button.visible = in_progress
	confirm_button.visible = in_progress
