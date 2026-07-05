extends Control
class_name ScorePanel

@onready var total_score_row = $HBox/VBox/TotalScoreRow
@onready var goal_score_row = $HBox/VBox/GoalScoreRow
@onready var turns_remaining_row = $HBox/VBox/TurnsRemainingRow
@onready var juice_tube = $HBox/JuiceTube

var score := 0:
	set(v):	
		score = v 
		juice_tube.value = v
		total_score_row.value = str(v)

var target_score: int:
	set(v):
		target_score = v 
		goal_score_row.value = str(v)
		if juice_tube:
			juice_tube.max_value = target_score
			
var turns_remaining: int:
	set(v):		
		turns_remaining = v 
		turns_remaining_row.value = str(v)
	
func target_met():
	return score >= target_score
