extends Panel
class_name ScorePanel

var WordScene = preload("res://components/scorer/word.tscn")

@onready var word_rows = $WordRows

func _ready():
	_demo()
	
func _demo():
	var words = ['GRAPE', 'SQUEEZE', 'VINE']
	for word in words:
		var scene = WordScene.instantiate()
		word_rows.add_child(scene)
		await scene.play(word)
		await get_tree().create_timer(0.3).timeout
