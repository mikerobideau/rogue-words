extends Node2D
class_name ScoreBox

@onready var letter_container = $Panel/VBoxContainer/LetterContainer
@onready var total_label = $Panel/VBoxContainer/TotalLabel
@onready var relic_container = $Panel/VBoxContainer/RelicContainer

func add_letter(letter: String, value: int):
	var col = VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var val_label = Label.new()
	val_label.text = str(value)
	val_label.add_theme_font_size_override("font_size", 10)
	val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var letter_label = Label.new()
	letter_label.text = letter
	letter_label.add_theme_font_size_override("font_size", 18)
	letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	col.add_child(val_label)
	col.add_child(letter_label)
	letter_container.add_child(col)
	
func show_total(total: int):
	total_label.text = str(total)
	total_label.visible = true

func update_total(new_total: int):
	total_label.text = str(new_total)
	
func shake_total():
	var tween = total_label.create_tween()
	tween.tween_property(total_label, 'position:x', total_label.position.x + 4, 0.03)
	tween.tween_property(total_label, 'position:x', total_label.position.x - 4, 0.03)
	tween.tween_property(total_label, 'position:x', total_label.position.x, 0.03)
	
func add_relic_line(relic_name: String, bonus_text: String):
	var label = Label.new()
	label.text = relic_name + ' -> ' + bonus_text
	label.add_theme_font_size_override('font_size', 12)
	relic_container.add_child(label)

	
