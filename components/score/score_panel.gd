extends Panel
class_name ScorePanel

var WordScene = preload("res://components/scorer/word.tscn")

@onready var word_rows = $MarginContainer/VBoxContainer/Body/WordRows
@onready var juice_tube = $MarginContainer/VBoxContainer/JuiceTube

func _ready():
	_demo()
	
func _demo():
	var words = ['GRAPED', 'VINE', 'SQUEEZE', 'ROGUELIKE']
	for word in words:
		var scene = WordScene.instantiate()
		word_rows.add_child(scene)
		word_rows.move_child(scene, 0)
		await scene.play(word)
		juice_tube.add(word.length() * 2)
		await get_tree().create_timer(0.3).timeout
