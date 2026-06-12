extends Node2D
class_name ScoringAnimator

const LETTER_DELAY := 0.1
const RELIC_DELAY := 1
const FADE_TIME := 0.4

var ScoreBoxOldScene = preload("res://components/scorer/score_box_old.tscn")
var ToastScene = preload("res://components/score_toast/score_toast.tscn")

func play(results: Array, relic_events: Array):
	for i in range(results.size()):
		var result = results[i]
		var relics = relic_events[i]
		await _animate_word(result, relics)
		await get_tree().create_timer(0.3).timeout
		
func _animate_word(result: Dictionary, relics: Array):
	var path = result.path
	var word = result.word
	var event = result.event
	
	var box = ScoreBoxOldScene.instantiate()
	add_child(box)
	box.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y - 400)
	
	#Step 1: Letters
	for i in range(path.size()):
		var space = path[i]
		var token = space.token
		var letter = token.letter
		var value = token.value
		
		token.pulse(LETTER_DELAY)
		var toast = ToastScene.instantiate()
		toast.text = str(token.value)
		toast.position = token.position
		add_child(toast)
		toast.animate()
		box.add_letter(letter, value)
		
		await get_tree().create_timer(LETTER_DELAY).timeout
		
	#Step 2: Total score
	box.show_total(event.score)
	await get_tree().create_timer(0.2).timeout
	
	#Step 3: Relics
	for relic_result in relics:
		box.add_relic_line(relic_result.name, relic_result.bonus_text)
		box.update_total(relic_result.new_total)
		box.shake_total()
		await get_tree().create_timer(RELIC_DELAY).timeout
	
	#Step 4: Fade out
	var tween = box.create_tween()
	tween.tween_property(box, 'modulate:a', 0, FADE_TIME)
	await tween.finished
	box.queue_free()
		
