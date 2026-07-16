extends Node
class_name RelicManager

var RelicScene = preload("res://components/relic/relic.tscn")

func on_token_placed(context: RelicContext):
	for relic in context.relics:
		var response = await relic.data.on_token_placed(context)
		if response:
			_activate_relic(relic, response, relic.data.get_on_placed_text(response))
			relic.data.data_changed.emit()
		
func get_score_report(context: RelicContext) -> RelicReport:
	var report = RelicReport.new()  
	var items: Array[RelicReportItem] = []
	for relic in context.relics:
		var before_score_response = relic.data.before_score(context) #triggers score events, e.g., money reward, decay/reset decay
		if before_score_response != RelicData.RelicResponse.NONE:
			relic.data.data_changed.emit()
			await _activate_relic(relic, before_score_response, relic.data.get_before_score_text(before_score_response))
		context.relic = relic
		var report_item = relic.data.get_score_report(context) #modifies current score (e.g., +50 or x2)
		if report_item:
			context.word_score = report_item.new_score
			items.append(report_item)
	if items.size() > 0:
		report.new_score = items[-1].new_score
	else:
		report.new_score = context.word_score
	report.items = items
	return report
	
func on_discard(context: RelicContext):
	for relic in context.relics:
		var response = relic.data.on_discard(context)
		if response:
			relic.data.data_changed.emit()
			await _activate_relic(relic, response, relic.data.get_discard_text(response))
			
func on_round_complete(context: RelicContext):
	for relic in context.relics:
		if relic.data.on_round_complete(context):
			await _activate_relic(relic)
			
func add_grow_amount(context: RelicContext):
	var expansions = 0
	for relic in context.relics:
		var bonus = relic.data.add_grow_amount(context)
		if bonus > 0:
			await _activate_relic(relic, RelicData.RelicResponse.NONE)
		expansions += bonus
	return expansions
	
func get_letter_matches(letter: String) -> Array:
	var matches = [letter]
	for relic_data in GameState.relics:
		matches = relic_data.modify_letter_matches(letter, matches)
	return matches

func _activate_relic(relic: Relic, response := RelicData.RelicResponse.NONE, text := ''):
	match response:
		RelicData.RelicResponse.NONE:
			return
		RelicData.RelicResponse.SCORE:	
			Sound.play(Sound.SOUND_RELIC_SCORE)
		RelicData.RelicResponse.UPGRADE:
			Sound.play(Sound.SOUND_RELIC_UPGRADE)
		RelicData.RelicResponse.DECAY:
			Sound.play(Sound.SOUND_RELIC_DECAY)
		RelicData.RelicResponse.RESET_NEGATIVE:
			Sound.play(Sound.SOUND_RELIC_RESET_NEGATIVE)
		RelicData.RelicResponse.RESET_POSITIVE:
			Sound.play(Sound.SOUND_RELIC_RESET_POSITIVE)
		RelicData.RelicResponse.MONEY_REWARD:
			Sound.play(Sound.SOUND_RELIC_MONEY)
		RelicData.RelicResponse.EVENT:
			pass
	print_debug('pulsing')
	relic.pulse()
	if text != null and text != '':
		ScorePopup.show(text, relic)
	await get_tree().create_timer(0.4).timeout
		
