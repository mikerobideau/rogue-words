extends RelicData
class_name PottyMouth

func get_score_report(context: RelicContext) -> RelicReportItem:
	if context.word.length() == 4:
		var report = RelicReportItem.new()
		_add_bonus(scale_by)
		report.relic = context.relic
		report.prev_score = context.word_score
		report.new_score = report.prev_score + bonus
		report.text = '+' + str(bonus)
		print_debug('returning report for relic ' + context.relic.data.relic_name)
		return report
	return null
