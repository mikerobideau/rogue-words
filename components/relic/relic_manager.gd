extends Node
class_name RelicManager

var RelicScene = preload("res://components/relic/relic.tscn")

func on_token_placed(context: RelicContext):
	for relic in context.relics:
		if await relic.data.on_token_placed(context):
			_activate_relic(relic)
		
func get_score_report(context: RelicContext) -> RelicReport:
	var report = RelicReport.new()
	var items: Array[RelicReportItem] = []
	for relic in context.relics:
		var has_event = relic.data.on_score_event(context) #triggers score events, e.g., money reward
		if has_event:
			_activate_relic(relic)
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
			
func add_grow_amount(context: RelicContext):
	var expansions = 0
	for relic in context.relics:
		var bonus = relic.data.add_grow_amount(context)
		if bonus > 0:
			_activate_relic(relic)
		expansions += bonus
	return expansions
	
func get_letter_matches(letter: String) -> Array:
	var matches = [letter]
	for relic_data in GameState.relics:
		matches = relic_data.modify_letter_matches(letter, matches)
	return matches

func _activate_relic(relic: Relic):
	Sound.play(Sound.SOUND_RELIC)
	relic.pulse()
