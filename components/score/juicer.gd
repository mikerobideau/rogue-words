extends Control
class_name ScorePanel

var WordScene = preload("res://components/score/word.tscn")

@onready var juice_tube = $MarginContainer/VBoxContainer/JuiceTube
@onready var round_label = $MarginContainer/VBoxContainer/HBoxContainer/RoundLabel
@onready var score_label = $MarginContainer/VBoxContainer/HBoxContainer/ScoreLabel
@onready var word = $MarginContainer/VBoxContainer/Word

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
	await word.play(word_report, relic_report)
	score += relic_report.new_score
	juice_tube.add(relic_report.new_score)

func target_met():
	return score >= target_score

func _update_score_label():
	score_label.text = str(score) + '/' + str(target_score)

func _update_round_label():
	round_label.text = 'Round ' + str(round_number)
