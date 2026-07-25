extends Panel
class_name ScorePanel

@onready var total_score_row = $HBox/VBox/TotalScoreRow
@onready var goal_score_row = $HBox/VBox/GoalScoreRow
@onready var turns_remaining_row = $HBox/VBox/TurnsRemainingRow
@onready var juice_tube = $HBox/JuiceTube

var x_in: int
var x_out: int
var slide_distance: int

func _ready():
	modulate.a = 0.0
	pivot_offset = size / 2

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
	
func slide_in(delay := 0.5):
	await get_tree().process_frame
	x_in = position.x
	slide_distance = size.x + 50
	x_out = x_in - slide_distance
	position.x = x_out
	modulate.a = 1.0
	await get_tree().create_timer(delay).timeout
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'position:x', x_in, 0.5)
