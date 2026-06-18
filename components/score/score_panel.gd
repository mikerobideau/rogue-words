extends Panel
class_name ScorePanel

var WordScene = preload("res://components/scorer/word.tscn")

@onready var word_rows = $MarginContainer/VBoxContainer/Body/WordRows
@onready var juice_tube = $MarginContainer/VBoxContainer/JuiceTube
@onready var round_label = $MarginContainer/VBoxContainer/HBoxContainer/RoundLabel
@onready var score_label = $MarginContainer/VBoxContainer/HBoxContainer/ScoreLabel

var score: int:
	set(v):
		score = v; _update_score_label()

var target_score: int:
	set(v):
		target_score = v; _update_score_label()
		juice_tube.max_value = target_score
		
var round_number: int:
	set(v):
		round_number = v; _update_round_label()

func play_word(word_report: WordReport, relic_report: RelicReport):
	var scene = WordScene.instantiate()
	word_rows.add_child(scene)
	word_rows.move_child(scene, 0)
	await scene.play(word_report, relic_report)
	score += relic_report.new_score
	juice_tube.add(relic_report.new_score)
	
func clear_words():
	for child in word_rows.get_children():
		child.queue_free()

func target_met():
	return score >= target_score

func _update_score_label():
	score_label.text = str(score) + '/' + str(target_score)

func _update_round_label():
	round_label.text = 'Round ' + str(round_number)
	
func _demo():
	var words = ['GRAPED', 'VINE', 'SQUEEZE', 'ROGUELIKE']
	for word in words:
		var scene = WordScene.instantiate()
		word_rows.add_child(scene)
		word_rows.move_child(scene, 0)
		await scene.play(word)
		juice_tube.add(word.length() * 2)
		scene.plunge_out()
		await get_tree().create_timer(0.3).timeout
