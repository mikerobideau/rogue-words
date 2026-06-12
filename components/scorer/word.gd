extends MarginContainer
class_name Word

var LetterScene = preload("res://components/scorer/letter.tscn")

@onready var letters = $Letters

func _ready():
	pivot_offset = size / 2
	pass

func add_letter(letter: String):
	var scene = LetterScene.instantiate()
	scene.letter = letter
	letters.add_child(scene)
	await get_tree().process_frame
	
func clear():
	for letter in letters.get_children():
		letter.queue_free()
